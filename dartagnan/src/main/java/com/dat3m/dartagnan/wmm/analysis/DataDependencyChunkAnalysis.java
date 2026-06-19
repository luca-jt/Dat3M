package com.dat3m.dartagnan.wmm.analysis;

import com.dat3m.dartagnan.program.Register;
import com.dat3m.dartagnan.program.analysis.ExecutionAnalysis;
import com.dat3m.dartagnan.program.analysis.ReachingDefinitionsAnalysis;
import com.dat3m.dartagnan.program.event.Event;
import com.dat3m.dartagnan.program.event.RegReader;
import com.dat3m.dartagnan.program.event.RegWriter;
import com.dat3m.dartagnan.program.event.Tag;
import com.dat3m.dartagnan.program.event.core.CondJump;
import com.dat3m.dartagnan.program.event.core.ExecutionStatus;
import com.dat3m.dartagnan.program.event.core.Label;
import com.dat3m.dartagnan.program.event.core.Local;
import com.dat3m.dartagnan.verification.Context;
import com.dat3m.dartagnan.verification.VerificationTask;
import org.apache.commons.lang3.tuple.Pair;

import java.util.*;
import java.util.function.Supplier;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.reverse;


public class DataDependencyChunkAnalysis {
    protected final VerificationTask task;
    protected final Context analysisContext;
    protected final ExecutionAnalysis exec;
    protected final ReachingDefinitionsAnalysis definitions;

    private final HashMap<Pair<Event, RegReader>, Boolean> edges_to_encode; // booleans store must-ness, edges are (if so) writer -> reader
    private final HashMap<RegReader, HashMap<Register, ArrayList<Pair<Event, Boolean>>>> reverse_edge_map;
    private final HashMap<Event, Boolean> chunk_borders;

    Map<Event, Label> preceding_labels = new HashMap<>(); // for each event: the nearest Label preceding it in linear program order
    Map<Label, List<CondJump>> jump_source_map = new HashMap<>(); // for each label: which CondJumps jump to it
    Map<Event, Event> linear_predecessor = new HashMap<>(); // for each event its immediate linear predecessor

    public DataDependencyChunkAnalysis(VerificationTask t, Context context) {
        task = checkNotNull(t);
        analysisContext = context;
        exec = context.requires(ExecutionAnalysis.class);
        definitions = context.requires(ReachingDefinitionsAnalysis.class);

        edges_to_encode = new HashMap<>();
        reverse_edge_map = new HashMap<>();
        chunk_borders = new HashMap<>();

        for (var thread : task.getProgram().getThreads()) {
            Label currentLabel = null;
            Event prev = null;
            for (Event e : thread.getEvents()) {
                if (prev != null) linear_predecessor.put(e, prev);
                if (e instanceof Label label) {
                    currentLabel = label;
                }
                if (currentLabel != null) preceding_labels.put(e, currentLabel);
                if (e instanceof CondJump cj) {
                    jump_source_map.computeIfAbsent(cj.getLabel(), k -> new ArrayList<>()).add(cj);
                }
                prev = e;
            }
        }

        HashSet<Event> visited_events = new HashSet<>();
        for (RegReader possible_sink : reverse(task.getProgram().getThreadEvents(RegReader.class))) {
            if (!isPossibleCunkBorder(possible_sink)) {
                continue;
            }
            if (visited_events.contains(possible_sink)) {
                continue;
            }
            visited_events.add(possible_sink);

            final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(possible_sink);
            for (Register register : writers.getUsedRegisters()) {
                final ReachingDefinitionsAnalysis.RegisterWriters reg = writers.ofRegister(register);
                final var must_writers = reg.getMustWriters();
                for (RegWriter writer : reverse(reg.getMayWriters())) {
                    addDependencyEdge(writer, possible_sink, visited_events, must_writers.contains(writer));
                }
            }
        }

        for (var entry : edges_to_encode.entrySet()) {
            final RegReader reader = entry.getKey().getRight();
            final var border = entry.getKey().getLeft();
            final var border_register_key = border instanceof RegWriter reg_writer ? reg_writer.getResultRegister() : null;
            final var is_must = entry.getValue();
            final var writer_map = reverse_edge_map.computeIfAbsent(reader, r -> new HashMap<>());
            final var writer_list = writer_map.computeIfAbsent(border_register_key, r -> new ArrayList<>());
            writer_list.add(Pair.of(border, is_must));
        }

        for (var to_list : reverse_edge_map.values().stream().flatMap(map -> map.values().stream()).toList()) {
            to_list.sort((c1, c2) -> c2.getLeft().compareTo(c1.getLeft())); // reverse program order
        }
    }

    private boolean isPossibleCunkBorder(Event event) {
        final var is_chunk_border_value = chunk_borders.get(event);
        if (is_chunk_border_value == null) {
            final Supplier<Boolean> value_computation = () -> {
                if (event.hasTag(Tag.NO_CARRY_DEPS)) return false;
                if (event.hasTag(Tag.MEMORY)) return true;
                if (event instanceof CondJump) return true;
                if (event instanceof Local local) {
                    final var result_reg = local.getResultRegister();
                    for (RegReader reader : event.getFunction().getEvents(RegReader.class).stream()
                            .filter(r -> r.getLocalId() > local.getLocalId())
                            .filter(this::isPossibleCunkBorder)
                            .toList()
                    ) {
                        final var fitting_read = reader.getRegisterReads().stream()
                                .filter(read -> read.register() == result_reg && read.usageType() == Register.UsageType.ADDR)
                                .findAny();

                        if (fitting_read.isPresent()) return true;
                    }
                }
                return false;
            };
            final var value = value_computation.get();
            chunk_borders.put(event, value);
            return value;
        } else {
            return is_chunk_border_value;
        }
    }

    public Set<Map.Entry<RegReader, HashMap<Register, ArrayList<Pair<Event, Boolean>>>>> getReverseReaderEntries() {
        return reverse_edge_map.entrySet();
    }

    public boolean hasNoEdgesToEncode() {
        return edges_to_encode.isEmpty();
    }

    private void addDependencyEdge(Event start, RegReader end_border, HashSet<Event> visited_events, boolean is_must_path) {
        var new_start = start;

        if (start instanceof ExecutionStatus status && status.doesTrackDep()) {
            new_start = status.getStatusEvent(); // status events are always writers tagged with MEMORY and are chunk borders
        }

        var new_end_border = end_border;
        final var start_is_chunk_border = isPossibleCunkBorder(new_start);

        if (start_is_chunk_border) {
            final var edge_key = Pair.of(new_start, end_border);
            edges_to_encode.merge(edge_key, is_must_path, (a, b) -> b || a);

            if (visited_events.contains(new_start)) return; // early return to prohibit exponential loops for cmpxchgs with status events

            if (new_start instanceof RegReader reader) {
                new_end_border = reader;
            }
            visited_events.add(new_start);
        }

        if (new_start instanceof RegReader reader) {
            final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(reader);
            for (Register register : writers.getUsedRegisters()) {
                final ReachingDefinitionsAnalysis.RegisterWriters reg = writers.ofRegister(register);
                final var must_writers = reg.getMustWriters();
                for (RegWriter writer : reverse(reg.getMayWriters())) {
                    var is_must_writer = must_writers.contains(writer);

                    if (writer instanceof Local local && !is_must_writer && !isPossibleCunkBorder(writer)) {
                        edges_to_encode.merge(Pair.of(local, new_end_border), false, Boolean::logicalOr);
                        if (visited_events.add(local)) {
                            var local_reader = (RegReader) local;
                            final ReachingDefinitionsAnalysis.Writers local_writers = definitions.getWriters(local_reader);
                            for (Register r : local_writers.getUsedRegisters()) {
                                final ReachingDefinitionsAnalysis.RegisterWriters regs = local_writers.ofRegister(r);
                                for (RegWriter w : reverse(regs.getMayWriters())) {
                                    addDependencyEdge(w, local, visited_events, false);
                                }
                            }
                        }
                    } else {
                        final var path_is_still_must = (is_must_path || start_is_chunk_border) && is_must_writer;
                        addDependencyEdge(writer, new_end_border, visited_events, path_is_still_must);
                    }
                }
            }
        }
/*
        final List<CondJump> controlling_jumps = new ArrayList<>();
        findControllingJumps(new_start, controlling_jumps);
        for (var jump : controlling_jumps) {
            addDependencyEdge(jump, new_end_border, visited_events, false);
        }*/
    }

    private void findControllingJumps(Event event, List<CondJump> jumps) {
        Label label = preceding_labels.get(event);
        if (label == null) return;

        final List<CondJump> jumpers = jump_source_map.getOrDefault(label, List.of());
        for (var jumper : jumpers) {
            if (!jumper.isGoto()) {
                jumps.add(jumper);
            } else if (linear_predecessor.get(jumper) instanceof CondJump pcj && !pcj.isGoto()) {
                jumps.add(pcj);
            } else {
                findControllingJumps(jumper, jumps);
            }
        }
    }
}
