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
import com.dat3m.dartagnan.verification.Context;
import com.dat3m.dartagnan.verification.VerificationTask;
import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;
import org.apache.commons.lang3.tuple.Pair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.function.Supplier;
import java.util.stream.Stream;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.reverse;


public class DataDependencyChunkAnalysis {
    private static final Logger logger = LoggerFactory.getLogger(DataDependencyChunkAnalysis.class);

    protected final VerificationTask task;
    protected final Context analysisContext;
    protected final ExecutionAnalysis exec;
    protected final ReachingDefinitionsAnalysis definitions;

    private final Map<Pair<Event, RegReader>, EdgeEncodingInfo> edges_to_encode; // edges are (if so) writer -> reader
    private final Map<Event, Boolean> chunk_borders;
    private final Set<Event> visited_sinks;
    private int event_count = -1;
    private final Map<com.dat3m.dartagnan.program.Thread, BiMap<Event, Integer>> event_bit_indices;
    private boolean analysis_ran = false;
    private final Map<RegReader, List<ConditionToBorder>> known_subpaths;
    private com.dat3m.dartagnan.program.Thread current_thread = null;
    private final Map<RegWriter, Integer> unvisited_reader_count;

    record ConditionToBorder(PathCondition condition, Event border) {}

    record EdgeEncodingInfo(List<PathCondition> conditions, BitSet eliminated_bits) {} // this way we don't need exponentially many conditions stored and we can prematurely eliminate stuff

    public DataDependencyChunkAnalysis(VerificationTask t, Context context) {
        task = checkNotNull(t);
        analysisContext = context;
        exec = context.requires(ExecutionAnalysis.class);
        definitions = context.requires(ReachingDefinitionsAnalysis.class);

        edges_to_encode = new LinkedHashMap<>();
        chunk_borders = new HashMap<>();
        visited_sinks = new HashSet<>();
        event_bit_indices = new HashMap<>();
        known_subpaths = new HashMap<>();
        unvisited_reader_count = new HashMap<>();
    }

    private void runAnalysis() {
        logger.info("Begin of DataDependencyAnalysis");

        final var thread_list = task.getProgram().getThreads();

        final Map<com.dat3m.dartagnan.program.Thread, List<Event>> thread_condition_events = new HashMap<>(thread_list.size());
        final Map<com.dat3m.dartagnan.program.Thread, List<RegReader>> thread_sink_events = new HashMap<>(thread_list.size());

        for (var thread : thread_list) {
            thread_condition_events.put(thread, new ArrayList<>());
            thread_sink_events.put(thread, new ArrayList<>());
        }

        task.getProgram().getThreadEvents().stream().map(e -> {
            if (e instanceof ExecutionStatus status && status.doesTrackDep()) return status.getStatusEvent(); // only writers and status events can be in the sets
            if (e instanceof RegWriter) return e;
            return null;
        }).filter(Objects::nonNull).forEach(event -> thread_condition_events.get(event.getThread()).add(event));

        for (var event : task.getProgram().getThreadEvents(RegReader.class)) { // only readers can be sinks
            thread_sink_events.get(event.getThread()).add(event);

            final var writers = definitions.getWriters(event);
            writers.getUsedRegisters().stream().flatMap(r -> writers.ofRegister(r).getMayWriters().stream()).forEach(writer -> unvisited_reader_count.merge(writer, 1, Integer::sum));
        }

        for (var entry : thread_sink_events.entrySet()) {
            current_thread = entry.getKey();
            final var sink_event_list = entry.getValue();
            final var all_condition_events = thread_condition_events.get(current_thread);
            event_count = all_condition_events.size();
            final var bit_index_map = event_bit_indices.computeIfAbsent(current_thread, t -> HashBiMap.create(event_count));
            for (int i = 0; i < all_condition_events.size(); i++) {
                bit_index_map.put(all_condition_events.get(i), i);
            }
            known_subpaths.clear();
            chunk_borders.clear();
            visited_sinks.clear();
            final Map<Pair<RegReader, Register>, List<RegWriter>> writer_cache = new HashMap<>();

            for (RegReader possible_sink : reverse(sink_event_list)) {
                if (!isChunkBorder(possible_sink)) {
                    continue;
                }
                if (visited_sinks.contains(possible_sink)) {
                    continue;
                }
                visited_sinks.add(possible_sink);

                addDependencyEdge(possible_sink, possible_sink, PathCondition.from_size(event_count), writer_cache);
            }
        }

        logger.info("End of DataDependencyAnalysis");
    }

    public Stream<Pair<Pair<Event, RegReader>, List<PathCondition>>> getEdgesToEncode() {
        if (!analysis_ran) {
            runAnalysis();
            analysis_ran = true;
        }
        return edges_to_encode.entrySet().stream().map(p -> Pair.of(p.getKey(), p.getValue().conditions()));
    }

    private void addEvent(BitSet bits, Event event) {
        final var index = event_bit_indices.get(current_thread).get(event);
        bits.set(index);
    }

    public Stream<Event> eventStreamOfSet(BitSet set, com.dat3m.dartagnan.program.Thread thread) {
        return set.stream().mapToObj(i -> event_bit_indices.get(thread).inverse().get(i));
    }

    private boolean isChunkBorder(Event event) {
        final var is_chunk_border_value = chunk_borders.get(event);
        if (is_chunk_border_value == null) {
            final Supplier<Boolean> value_computation = () -> {
                if (event.hasTag(Tag.NO_CARRY_DEPS)) return false;
                if (event.hasTag(Tag.MEMORY)) return true;
                if (event instanceof CondJump) return true;
                if (event instanceof RegWriter w) {
                    final var result_reg = w.getResultRegister();
                    for (RegReader reader : event.getFunction().getEvents(RegReader.class).stream()
                            .filter(r -> r.getLocalId() > w.getLocalId())
                            .filter(this::isChunkBorder)
                            .toList()
                    ) {
                        final var fitting_read_is_present = reader.getRegisterReads().stream().anyMatch(read -> read.register() == result_reg && read.usageType() == Register.UsageType.ADDR);
                        if (fitting_read_is_present) return true;
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

    private List<ConditionToBorder> addDependencyEdge(RegReader current_node, RegReader sink, PathCondition accumulated_condition, Map<Pair<RegReader, Register>, List<RegWriter>> writer_cache) {
        final List<ConditionToBorder> paths_from_current = new ArrayList<>();

        final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(current_node);
        for (Register register : writers.getUsedRegisters()) {
            final var may_writers = writer_cache.computeIfAbsent(Pair.of(current_node, register), p -> writers.ofRegister(p.getRight()).getMayWriters());

            final BitSet overwrites = new BitSet(event_count);

            for (int writer_index = may_writers.size() - 1; writer_index >= 0; writer_index--) {
                final var writer = may_writers.get(writer_index);
                final PathCondition link_condition = PathCondition.from_size(event_count);

                link_condition.forbidden().or(overwrites);
                accumulated_condition.forbidden().or(overwrites);

                final Event possible_border = (writer instanceof ExecutionStatus status && status.doesTrackDep()) ? status.getStatusEvent() : writer; // status events are always writers tagged with MEMORY and are chunk borders
                final var is_conditionally_must = exec.isImplied(current_node, possible_border);

                var sink_for_next_call = sink;
                var accumulated_condition_for_next_call = accumulated_condition;
                final var is_chunk_border = isChunkBorder(possible_border);

                if (is_chunk_border) {
                    final var condition_to_border = new ConditionToBorder(new PathCondition(link_condition), possible_border);
                    paths_from_current.add(condition_to_border);

                    if (!visited_sinks.add(possible_border)) continue; // early return to prohibit multiple visits

                    if (possible_border instanceof RegReader reader) {
                        sink_for_next_call = reader;
                        accumulated_condition_for_next_call = PathCondition.from_size(event_count);
                    }
                } else if (!is_conditionally_must) {
                    if (possible_border instanceof RegReader && eventStreamOfSet(accumulated_condition.required(), current_thread).anyMatch(req -> req == possible_border)) { // TODO: this check fine?
                        // essentially white/grey/black DFS to avoid loops like in the safe_stack example
                        accumulated_condition.forbidden().andNot(overwrites);
                        maybeReleaseKnownPaths(possible_border);
                        addEvent(overwrites, possible_border);
                        continue;
                    } else {
                        addEvent(link_condition.required(), possible_border);
                        accumulated_condition.required().or(link_condition.required());
                    }
                }

                // TODO: try only stored links
                // TODO: tackle failing tests
                // TODO: premature merge only better for worst case examples?

                if (possible_border instanceof RegReader reader) {
                    if (is_chunk_border) {
                        final var subpaths_from_reader = addDependencyEdge(reader, sink_for_next_call, accumulated_condition_for_next_call, writer_cache);
                        assert subpaths_from_reader.isEmpty();
                    } else {
                        var subpaths_from_reader = known_subpaths.get(reader);
                        if (subpaths_from_reader == null) {
                            subpaths_from_reader = addDependencyEdge(reader, sink_for_next_call, accumulated_condition_for_next_call, writer_cache);
                            if (possible_border instanceof RegWriter border_writer && unvisited_reader_count.getOrDefault(border_writer, 0) > 1) {
                                known_subpaths.put(reader, subpaths_from_reader);
                            }
                        }

                        maybeReleaseKnownPaths(possible_border);

                        final List<ConditionToBorder> subpaths_to_add_to_current = updateConditionsToBorders(subpaths_from_reader, link_condition);
                        paths_from_current.addAll(subpaths_to_add_to_current);
                    }
                }

                accumulated_condition.remove(link_condition);
                addEvent(overwrites, possible_border);
            }
        }

        if (current_node == sink) {
            for (var condition_to_border : paths_from_current) {
                final var edge_key = Pair.of(condition_to_border.border, sink);
                final var info = edges_to_encode.computeIfAbsent(edge_key, k -> new EdgeEncodingInfo(new ArrayList<>(2), new BitSet(event_count))); // most of the time there are only one or two paths
                if (!condition_to_border.condition.isStructAndCondMust()) {
                    info.conditions().add(condition_to_border.condition);

                    // prematurely eliminate stuff and remove tautologies
                    final BitSet intersection = new BitSet(event_count);
                    info.conditions().stream().map(PathCondition::required).forEach(intersection::or);

                    final BitSet all_forbidden = new BitSet(event_count);
                    info.conditions().stream().map(PathCondition::forbidden).forEach(all_forbidden::or);

                    intersection.and(all_forbidden);
                    info.eliminated_bits().or(intersection);

                    info.conditions().removeIf(existing_condition -> {
                        existing_condition.required().andNot(info.eliminated_bits());
                        existing_condition.forbidden().andNot(info.eliminated_bits());
                        return existing_condition.isStructAndCondMust();
                    });

                    if (!info.conditions().isEmpty()) {
                        final var unique = new HashSet<>(info.conditions());
                        info.conditions().clear();
                        info.conditions().addAll(unique);
                    }
                } else {
                    info.conditions().clear();
                }
            }
            return List.of();
        }

        if (paths_from_current.isEmpty()) return List.of();

        return paths_from_current;
    }

    private void maybeReleaseKnownPaths(Event possible_border) {
        if (possible_border instanceof RegWriter border_writer && possible_border instanceof RegReader reader) {
            final var new_value = unvisited_reader_count.computeIfPresent(border_writer, (w, i) -> i > 1 ? i - 1 : null);
            if (new_value == null) known_subpaths.remove(reader);
        }
    }

    private static List<ConditionToBorder> updateConditionsToBorders(List<ConditionToBorder> subpaths_from_reader, PathCondition link_condition) {
        final List<ConditionToBorder> subpaths_to_add_to_current = new ArrayList<>(subpaths_from_reader.size());
        for (var cond_to_border : subpaths_from_reader) {
            final var cond_to_border_with_link = new ConditionToBorder(new PathCondition(cond_to_border.condition()), cond_to_border.border);
            cond_to_border_with_link.condition().merge(link_condition);
            subpaths_to_add_to_current.add(cond_to_border_with_link);
        }
        return subpaths_to_add_to_current;
    }
}
