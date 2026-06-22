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

    public DataDependencyChunkAnalysis(VerificationTask t, Context context) {
        task = checkNotNull(t);
        analysisContext = context;
        exec = context.requires(ExecutionAnalysis.class);
        definitions = context.requires(ReachingDefinitionsAnalysis.class);

        edges_to_encode = new HashMap<>();
        reverse_edge_map = new HashMap<>();
        chunk_borders = new HashMap<>();

        HashSet<Event> visited_events = new HashSet<>();
        for (RegReader possible_sink : reverse(task.getProgram().getThreadEvents(RegReader.class))) {
            if (!isChunkBorder(possible_sink)) {
                continue;
            }
            if (visited_events.contains(possible_sink)) {
                continue;
            }
            visited_events.add(possible_sink);

            addDependencyEdge(possible_sink, possible_sink, visited_events, true);
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

    private boolean isChunkBorder(Event event) {
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
                            .filter(this::isChunkBorder)
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

    private void addDependencyEdge(RegReader current_node, RegReader sink, HashSet<Event> visited_events, boolean is_must_path) {
        final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(current_node);
        for (Register register : writers.getUsedRegisters()) {
            final ReachingDefinitionsAnalysis.RegisterWriters reg = writers.ofRegister(register);
            final var must_writers = reg.getMustWriters();
            final var may_writers = reg.getMayWriters();
            final var may_writer_set = new HashSet<>(may_writers);

            for (RegWriter writer : reverse(may_writers)) {
                var is_still_must_path = is_must_path && must_writers.contains(writer) && exec.isImplied(current_node, writer); // TODO: this currently uses some unnecessary edge vars, we could split must-ness and collapsibility and store execution conditions on edges that can be merged with OR if two paths meet. the collapse can happen if the conditions simplify to true... worth it? are the tautologies detectable? just check if end implies start?

                if (!is_still_must_path && writer instanceof Local local) {
                    is_still_must_path = isChainTransparent(local, register, may_writer_set);
                }

                Event possible_border = writer;
                if (possible_border instanceof ExecutionStatus status && status.doesTrackDep()) {
                    possible_border = status.getStatusEvent(); // status events are always writers tagged with MEMORY and are chunk borders
                }

                final var writer_is_chunk_border = isChunkBorder(possible_border) || (possible_border instanceof Local && !is_still_must_path);

                // TODO: if we build the full graph first, we could completely reason about what edges can be collapsed and must-ness properties... this would mean the collapsing would be a graph property: find SCCs of writer families for a register and check what nodes have all predecessors inside the family and no external chunk border reads and collapse them. this would be great to combine with the edge exectution conditions and mustness separation. this would reduce node revisits during the bottom-up traversal.

                var new_sink = sink;
                if (writer_is_chunk_border) {
                    final var edge_key = Pair.of(possible_border, sink);
                    edges_to_encode.merge(edge_key, is_still_must_path, (a, b) -> b || a);
                    if (!visited_events.add(possible_border)) continue; // early return to prohibit exponential loops for cmpxchgs with status events
                    if (possible_border instanceof RegReader reader) new_sink = reader;
                }

                if (possible_border instanceof RegReader reader) {
                    addDependencyEdge(reader, new_sink, visited_events, is_still_must_path || writer_is_chunk_border);
                }
            }
        }
    }

    private boolean isChainTransparent(Local local, Register register, Set<RegWriter> sink_may_writers) {
        final var local_writers = definitions.getWriters(local);
        boolean reads_sink_register = false;

        for (var read : local.getRegisterReads()) {
            if (read.register() == register) {
                // every may-source of the sinks read register must be within the family
                for (var pred : local_writers.ofRegister(register).getMayWriters()) { // TODO: this check could be better
                    if (!sink_may_writers.contains(pred)) return false;
                }
                reads_sink_register = true;
            } else {
                // no chunk border source of any other register falls outside the family
                for (var pred : local_writers.ofRegister(read.register()).getMayWriters()) {
                    if (isChunkBorder(pred) && !sink_may_writers.contains(pred)) return false; // TODO: could there be a case where isChunkBorder is not sufficient and we need the local check from above to fire here?
                }
            }
        }

        return reads_sink_register; // pure constant writers are never transparent
    }
}
