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

    private final Map<Pair<Event, RegReader>, List<PathCondition>> edges_to_encode; // edges are (if so) writer -> reader
    private final Map<Event, Boolean> chunk_borders;

    public DataDependencyChunkAnalysis(VerificationTask t, Context context) {
        task = checkNotNull(t);
        analysisContext = context;
        exec = context.requires(ExecutionAnalysis.class);
        definitions = context.requires(ReachingDefinitionsAnalysis.class);

        edges_to_encode = new HashMap<>();
        chunk_borders = new HashMap<>();

        final HashSet<Event> visited_sinks = new HashSet<>();
        for (RegReader possible_sink : reverse(task.getProgram().getThreadEvents(RegReader.class))) {
            if (!isChunkBorder(possible_sink)) {
                continue;
            }
            if (visited_sinks.contains(possible_sink)) {
                continue;
            }
            visited_sinks.add(possible_sink);

            addDependencyEdge(possible_sink, possible_sink, visited_sinks, new PathCondition(Set.of(), Set.of()));
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

    /*
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

                final var writer_is_chunk_border = isChunkBorder(possible_border) || (possible_border instanceof Local && !is_still_must_path); // TODO: the only reason this works for now is because this makes the overwrite appear in the encoding

                // TODO: build the entire graph bottom-up
                // do collapsing through true must edges on the fly, otherwhise, add edges to graph with execution conditions using all writers (multiple collapsed links are ANDed)
                // on a join of two paths check if all execution condtions OR'ed are true
                // tree gets simplified to O(2^n) direct edges with the conditions that connect chunk borders
                // structural must-edges should be tracked with conditions as well, store the structural must-ness per-edge
                // if execution conditions on path meet simplify to true, no edge variable is needed
                // bridging implication chains by ANDing structural must-ness on paths so simplify conditions later on (maybe caching of the full condition is needed for collapse checks)
                // the collapse checks could be aided by graph structure checks??
                // use a variable if there is a single structural non-must edge on a path

                // conditional must determines if the implication chain can be briged, structural must-ness determines if there needs to be a variable
                // on every link that you look at, if the link is conditional may-only, add an execution condition, if the link is structural may-only, add an overwrite condition
                // the adding of the overwrites can be reduced by using the chain transparency function
                // skip the overwrite condition if it is mutually exclusive to the sink
                // if we need a new execution condition, check if the execution is not already implied by some other execution that we recorded as required on this path???
                // if two paths are merged, remove execution conditions if one path requires and one path forbids

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
    }*/

    public Set<Map.Entry<Pair<Event, RegReader>, List<PathCondition>>> getEdgesToEncode() {
        return edges_to_encode.entrySet();
    }

    private void addDependencyEdge(RegReader current_node, RegReader sink, HashSet<Event> visited_events, PathCondition built_condition) {
        final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(current_node);
        for (Register register : writers.getUsedRegisters()) {
            final ReachingDefinitionsAnalysis.RegisterWriters reg = writers.ofRegister(register);
            final var may_writers = reg.getMayWriters();
            final List<Event> overwrites = new ArrayList<>();

            for (RegWriter writer : reverse(may_writers)) {
                final var path_condition = new PathCondition(built_condition);

                for (var overwrite : overwrites) {
                    if (!exec.areMutuallyExclusive(overwrite, writer)) {
                        path_condition.forbidden().add(overwrite); // TODO: iterate in reverse and only add overwrites that do not imply the excution of an already added one?
                    }
                }

                final Event possible_border = (writer instanceof ExecutionStatus status && status.doesTrackDep()) ? status.getStatusEvent() : writer; // status events are always writers tagged with MEMORY and are chunk borders

                var updated_sink = sink;
                var updated_path_condition = path_condition;

                if (isChunkBorder(possible_border)) {
                    final var edge_key = Pair.of(possible_border, sink);
                    final var condition_list = edges_to_encode.computeIfAbsent(edge_key, k -> new ArrayList<>());
                    final Set<Event> removed_from_new = new HashSet<>();

                    condition_list.removeIf(existing_condition -> {
                        final Set<Event> forbidden_existing_required = new HashSet<>(existing_condition.required());
                        forbidden_existing_required.retainAll(path_condition.forbidden());
                        final Set<Event> forbidden_new_required = new HashSet<>(path_condition.required());
                        forbidden_new_required.retainAll(existing_condition.forbidden());

                        removed_from_new.addAll(forbidden_existing_required); // remove tautologies
                        removed_from_new.addAll(forbidden_new_required);

                        existing_condition.required().removeAll(forbidden_existing_required);
                        existing_condition.forbidden().removeAll(forbidden_new_required);

                        return existing_condition.isStructAndCondMust();
                    });

                    path_condition.required().removeAll(removed_from_new);
                    path_condition.forbidden().removeAll(removed_from_new);

                    if (!path_condition.isStructAndCondMust()) {
                        condition_list.add(path_condition);
                    }

                    /*
                    transitive case: a single pair merge does not produce an empty condition
                    A: x
                    B: y, ¬x
                    C: z, ¬y, ¬x
                    */

                    if (!visited_events.add(possible_border)) continue; // early return to prohibit exponential loops for cmpxchgs with status events
                    if (possible_border instanceof RegReader reader) {
                        updated_sink = reader;
                        updated_path_condition = new PathCondition(Set.of(), Set.of());
                    }
                } else {
                    final var is_conditionally_must = exec.isImplied(current_node, possible_border);
                    if (!is_conditionally_must) {
                        //var is_already_implied = path_condition.required().stream().anyMatch(req -> exec.isImplied(req, possible_border));
                        path_condition.required().add(possible_border);
                    }
                }

                if (possible_border instanceof RegReader reader) {
                    addDependencyEdge(reader, updated_sink, visited_events, updated_path_condition);
                }

                if (!exec.areMutuallyExclusive(current_node, possible_border)) overwrites.add(possible_border);
            }
        }
    }
}
