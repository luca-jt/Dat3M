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
import java.util.stream.Collectors;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.reverse;


public class DataDependencyChunkAnalysis {
    protected final VerificationTask task;
    protected final Context analysisContext;
    protected final ExecutionAnalysis exec;
    protected final ReachingDefinitionsAnalysis definitions;

    private final Map<Pair<Event, RegReader>, List<PathCondition>> edges_to_encode; // edges are (if so) writer -> reader
    private final Map<Event, Boolean> chunk_borders;
    private final Set<Event> visited_sinks;

    public DataDependencyChunkAnalysis(VerificationTask t, Context context) {
        task = checkNotNull(t);
        analysisContext = context;
        exec = context.requires(ExecutionAnalysis.class);
        definitions = context.requires(ReachingDefinitionsAnalysis.class);

        edges_to_encode = new HashMap<>();
        chunk_borders = new HashMap<>();
        visited_sinks = new HashSet<>();

        for (RegReader possible_sink : reverse(task.getProgram().getThreadEvents(RegReader.class))) {
            if (!isChunkBorder(possible_sink)) {
                continue;
            }
            if (visited_sinks.contains(possible_sink)) {
                continue;
            }
            visited_sinks.add(possible_sink);

            addDependencyEdge(possible_sink, possible_sink, new PathCondition(new HashSet<>(), new HashSet<>()));
        }

        edges_to_encode.forEach((key, condition_list) -> {
            final Set<Event> intersection = condition_list.stream().flatMap(c -> c.required().stream()).collect(Collectors.toSet());
            final Set<Event> all_forbidden = condition_list.stream().flatMap(c -> c.forbidden().stream()).collect(Collectors.toSet());
            intersection.retainAll(all_forbidden); // remove tautologies

            condition_list.removeIf(existing_condition -> {
                existing_condition.required().removeAll(intersection);
                existing_condition.forbidden().removeAll(intersection);
                return existing_condition.isStructAndCondMust();
            });

            if (!condition_list.isEmpty()) {
                final var unique = new HashSet<>(condition_list);
                condition_list.clear();
                condition_list.addAll(unique);
            }
        });
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

    //var is_still_must_path = is_must_path && must_writers.contains(writer) && exec.isImplied(current_node, writer);
    // TODO: this currently uses some unnecessary edge vars, we could split must-ness and collapsibility and store execution conditions on edges that can be merged with OR if two paths meet. the collapse can happen if the conditions simplify to true... worth it? are the tautologies detectable? just check if end implies start?

    //final var writer_is_chunk_border = isChunkBorder(possible_border) || (possible_border instanceof Local && !is_still_must_path);
    // TODO: the only reason this works for now is because this makes the overwrite appear in the encoding

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

    /*
    transitive case: a single pair merge does not produce an empty condition
    A: x
    B: y, ¬x
    C: z, ¬y, ¬x
    */

    public Set<Map.Entry<Pair<Event, RegReader>, List<PathCondition>>> getEdgesToEncode() {
        return edges_to_encode.entrySet();
    }

    private void addDependencyEdge(RegReader current_node, RegReader sink, PathCondition path_condition) {
        final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(current_node);
        for (Register register : writers.getUsedRegisters()) {
            final ReachingDefinitionsAnalysis.RegisterWriters reg = writers.ofRegister(register);
            final var may_writers = reg.getMayWriters();
            final List<Event> overwrites = new ArrayList<>();

            for (RegWriter writer : reverse(may_writers)) {
                final var overwrites_added = new HashSet<Event>();
                for (var overwrite : reverse(overwrites)) {
                    if (!exec.areMutuallyExclusive(overwrite, writer) && overwrites_added.stream().noneMatch(added -> exec.isImplied(overwrite, added))) {
                        path_condition.forbidden().add(overwrite);
                        overwrites_added.add(overwrite);
                    }
                }

                final Event possible_border = (writer instanceof ExecutionStatus status && status.doesTrackDep()) ? status.getStatusEvent() : writer; // status events are always writers tagged with MEMORY and are chunk borders
                final var is_conditionally_must = exec.isImplied(current_node, possible_border);

                var updated_sink = sink;
                var updated_path_condition = path_condition;

                if (isChunkBorder(possible_border)) {
                    final var edge_key = Pair.of(possible_border, sink);
                    final var condition_list = edges_to_encode.computeIfAbsent(edge_key, k -> new ArrayList<>());
                    if (!path_condition.isStructAndCondMust()) {
                        condition_list.add(new PathCondition(path_condition));
                    }

                    if (!visited_sinks.add(possible_border)) continue; // early return to prohibit exponential loops for cmpxchgs with status events

                    if (possible_border instanceof RegReader reader) {
                        updated_sink = reader;
                        updated_path_condition = new PathCondition(new HashSet<>(), new HashSet<>());
                    }
                } else {
                    if (!is_conditionally_must) {
                        //var is_already_implied = path_condition.required().stream().anyMatch(req -> exec.isImplied(req, possible_border));
                        path_condition.required().add(possible_border);
                    }
                }

                if (possible_border instanceof RegReader reader) {
                    addDependencyEdge(reader, updated_sink, updated_path_condition);
                }

                if (!is_conditionally_must) {
                    path_condition.required().remove(possible_border);
                }
                overwrites_added.forEach(path_condition.forbidden()::remove);

                overwrites.add(possible_border);
            }
        }
    }
}
