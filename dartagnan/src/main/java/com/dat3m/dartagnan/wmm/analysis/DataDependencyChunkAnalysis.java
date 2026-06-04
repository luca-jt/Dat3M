package com.dat3m.dartagnan.wmm.analysis;

import com.dat3m.dartagnan.program.Register;
import com.dat3m.dartagnan.program.analysis.ExecutionAnalysis;
import com.dat3m.dartagnan.program.analysis.ReachingDefinitionsAnalysis;
import com.dat3m.dartagnan.program.event.Event;
import com.dat3m.dartagnan.program.event.RegReader;
import com.dat3m.dartagnan.program.event.RegWriter;
import com.dat3m.dartagnan.program.event.Tag;
import com.dat3m.dartagnan.program.event.core.CondJump;
import com.dat3m.dartagnan.program.event.core.Local;
import com.dat3m.dartagnan.verification.Context;
import com.dat3m.dartagnan.verification.VerificationTask;
import org.apache.commons.lang3.tuple.Pair;

import java.util.*;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.reverse;


public class DataDependencyChunkAnalysis {
    protected final VerificationTask task;
    protected final Context analysisContext;
    protected final ExecutionAnalysis exec;
    protected final ReachingDefinitionsAnalysis definitions;

    private final HashMap<Pair<RegWriter, RegReader>, Boolean> edges_to_encode; // booleans store must-ness
    private final HashMap<RegReader, HashMap<Register, ArrayList<Pair<RegWriter, Boolean>>>> reverse_edge_map;
    private final HashMap<Event, Boolean> chunk_borders;

    public DataDependencyChunkAnalysis(VerificationTask t, Context context) {
        task = checkNotNull(t);
        analysisContext = context;
        exec = context.requires(ExecutionAnalysis.class);
        definitions = context.requires(ReachingDefinitionsAnalysis.class);

        edges_to_encode = new HashMap<>();
        reverse_edge_map = new HashMap<>();
        chunk_borders = new HashMap<>();
    }

    public void run() { // TODO: where to insert? interface?
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
            final RegWriter border = entry.getKey().getLeft();
            final var is_must = entry.getValue();
            final var writer_map = reverse_edge_map.computeIfAbsent(reader, r -> new HashMap<>());
            final var writer_list = writer_map.computeIfAbsent(border.getResultRegister(), r -> new ArrayList<>());
            writer_list.add(Pair.of(border, is_must));
        }

        for (var to_list : reverse_edge_map.values().stream().flatMap(map -> map.values().stream()).toList()) {
            to_list.sort((c1, c2) -> c2.getLeft().compareTo(c1.getLeft())); // reverse program order
        }
    }

    private boolean isPossibleCunkBorder(Event event) {
        return chunk_borders.computeIfAbsent(event, e -> {
            if (e.hasTag(Tag.NO_CARRY_DEPS)) return false;
            if (e.hasTag(Tag.MEMORY)) return true;
            if (e instanceof CondJump) return true; // is not writing anyways, so these will only be sinks
            //if (e instanceof ExecutionStatus) return true; // For the edges to status events
            if (e instanceof Local local) {
                final var result_reg = local.getResultRegister();
                for (RegReader reader : e.getFunction().getEvents(RegReader.class).stream()
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
        });
    }

    public Set<Map.Entry<RegReader, HashMap<Register, ArrayList<Pair<RegWriter, Boolean>>>>> getReverseReaderEntries() {
        return reverse_edge_map.entrySet();
    }

    public boolean hasNoEdgesToEncode() {
        return edges_to_encode.isEmpty();
    }

    private void addDependencyEdge(RegWriter start, RegReader end_border, HashSet<Event> visited_events, boolean is_must_path) {
        RegReader new_end_border = end_border;
        final var start_is_chunk_border = isPossibleCunkBorder(start);

        if (start_is_chunk_border) {
            final var edge_key = Pair.of(start, end_border);
            edges_to_encode.merge(edge_key, is_must_path, (a, b) -> b || a);

            if (start instanceof RegReader reader) {
                new_end_border = reader;
            }
            visited_events.add(start);
        }

        if (start instanceof RegReader reader) {
            final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(reader);
            for (Register register : writers.getUsedRegisters()) {
                final ReachingDefinitionsAnalysis.RegisterWriters reg = writers.ofRegister(register);
                final var must_writers = reg.getMustWriters();
                for (RegWriter writer : reverse(reg.getMayWriters())) {
                    final var path_is_still_must = (is_must_path || start_is_chunk_border) && must_writers.contains(writer);
                    addDependencyEdge(writer, new_end_border, visited_events, path_is_still_must);
                }
            }
        }
    }
}
