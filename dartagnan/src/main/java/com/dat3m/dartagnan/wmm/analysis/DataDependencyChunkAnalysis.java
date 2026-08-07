package com.dat3m.dartagnan.wmm.analysis;

import com.dat3m.dartagnan.program.Register;
import com.dat3m.dartagnan.program.analysis.BackwardsReachingDefinitionsAnalysis;
import com.dat3m.dartagnan.program.analysis.ExecutionAnalysis;
import com.dat3m.dartagnan.program.analysis.ReachingDefinitionsAnalysis;
import com.dat3m.dartagnan.program.event.*;
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
import java.util.stream.Stream;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.reverse;


public class DataDependencyChunkAnalysis {
    private static final Logger logger = LoggerFactory.getLogger(DataDependencyChunkAnalysis.class);

    protected final VerificationTask task;
    protected final Context analysisContext;
    protected final ExecutionAnalysis exec;
    protected final ReachingDefinitionsAnalysis definitions;

    private final Map<Pair<Event, RegReader>, EdgeEncodingInfo> edges_to_encode;
    private final Set<Event> visited_sinks;
    private int event_count = -1;
    private final Map<com.dat3m.dartagnan.program.Thread, BiMap<Event, Integer>> event_bit_indices;
    private boolean analysis_ran = false;
    private com.dat3m.dartagnan.program.Thread current_thread = null;

    private final Map<List<RegWriter>, PhantomEvent> phantom_event_map;
    private final Set<Register> registers_with_phantom_events;
    private final Map<Pair<Event, RegReader>, EdgeEncodingInfo> edges_to_encode_with_phantom_start;
    private final Map<Pair<Event, RegReader>, EdgeEncodingInfo> edges_to_encode_with_phantom_end;
    private final Map<Pair<Event, RegReader>, EdgeEncodingInfo> edges_to_encode_with_both_phantom;
    private final Map<PhantomEvent, Set<Pair<Event, RegReader>>> edge_keys_for_phantom_start_edges;
    private final Map<Pair<Event, RegReader>, List<EncodingInfo>> final_edges;

    public interface EncodingInfo {
        boolean is_must();
    }

    public record EdgeEncodingInfo(List<PathCondition> conditions, AddrLinkKind addr_kind) implements EncodingInfo {
        @Override
        public boolean is_must() {
            return conditions().isEmpty();
        }
    }

    public record LinkedEdgeEncodingInfo(List<EdgeEncodingInfo> link_infos, List<PhantomEvent> phantoms) implements EncodingInfo {
        static LinkedEdgeEncodingInfo clone(LinkedEdgeEncodingInfo other) {
            return new LinkedEdgeEncodingInfo(new ArrayList<>(other.link_infos()), new ArrayList<>(other.phantoms()));
        }

        @Override
        public boolean is_must() {
            return false;
        }
    }

    enum AddrLinkKind {
        NONE(0x1), PURE(0x2), PART(0x3);
        final int index;

        AddrLinkKind(int index) {
            this.index = index;
        }

        public AddrLinkKind merge(AddrLinkKind other) {
            return switch (this.index | other.index) {
                case 0x1 -> NONE;
                case 0x2 -> PURE;
                default  -> PART;   // 0x3
            };
        }

        public AddrLinkKind add(AddrLinkKind other) {
            return index > other.index ? this : other;
        }

        static AddrLinkKind fromUsageType(Register.UsageType type) {
            return type == Register.UsageType.ADDR ? PURE : NONE;
        }
    }

    public DataDependencyChunkAnalysis(VerificationTask t, Context context) {
        task = checkNotNull(t);
        analysisContext = context;
        exec = context.requires(ExecutionAnalysis.class);
        definitions = context.requires(ReachingDefinitionsAnalysis.class);

        edges_to_encode = new LinkedHashMap<>();
        visited_sinks = new HashSet<>();
        event_bit_indices = new HashMap<>();
        phantom_event_map = new HashMap<>();
        registers_with_phantom_events = new HashSet<>();
        edges_to_encode_with_phantom_start = new LinkedHashMap<>();
        edges_to_encode_with_phantom_end = new LinkedHashMap<>();
        edges_to_encode_with_both_phantom = new LinkedHashMap<>();
        edge_keys_for_phantom_start_edges = new HashMap<>();
        final_edges = new LinkedHashMap<>();
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

        task.getProgram().getThreadEvents().stream().filter(e -> e instanceof RegWriter).forEach(event -> thread_condition_events.get(event.getThread()).add(event));

        for (var event : task.getProgram().getThreadEvents(RegReader.class)) { // only readers can be sinks
            thread_sink_events.get(event.getThread()).add(event);
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
            visited_sinks.clear();
            phantom_event_map.clear();
            registers_with_phantom_events.clear();

            for (RegReader possible_sink : reverse(sink_event_list)) {
                if (!isChunkBorder(possible_sink)) continue;
                if (!visited_sinks.add(possible_sink)) continue;
                addDependencyEdge(possible_sink, possible_sink, PathCondition.from_size(event_count), AddrLinkKind.NONE);
            }
        }

        Stream.concat(Stream.concat(Stream.concat(
                edges_to_encode.entrySet().stream().filter(e -> !e.getValue().conditions().isEmpty()),
                edges_to_encode_with_phantom_end.entrySet().stream().filter(e -> !e.getValue().conditions().isEmpty())),
                edges_to_encode_with_phantom_start.entrySet().stream().filter(e -> !e.getValue().conditions().isEmpty())),
                edges_to_encode_with_both_phantom.entrySet().stream().filter(e -> !e.getValue().conditions().isEmpty())
        ).forEach(e -> {
            final var info = e.getValue();
            if (info.conditions().stream().anyMatch(PathCondition::isStructAndCondMust)) {
                info.conditions().clear();
            }
        });

        for (var entry : edges_to_encode.entrySet()) {
            final_edges.merge(entry.getKey(), List.of(entry.getValue()), (l1, l2) -> {
                final List<EncodingInfo> result = new ArrayList<>(l1.size() + l2.size());
                result.addAll(l1);
                result.addAll(l2);
                return result;
            });
        }

        for (var start_entry : edges_to_encode_with_phantom_end.entrySet()) {
            final List<Pair<RegReader, LinkedEdgeEncodingInfo>> edge_ends = new ArrayList<>();
            buildLinkedEdgeConditions(start_entry.getKey(), edge_ends, new LinkedEdgeEncodingInfo(new ArrayList<>(), new ArrayList<>()));
            for (var edge_end : edge_ends) {
                final_edges.merge(Pair.of(start_entry.getKey().getLeft(), edge_end.getKey()), List.of(edge_end.getValue()), (l1, l2) -> {
                    final List<EncodingInfo> result = new ArrayList<>(l1.size() + l2.size());
                    result.addAll(l1);
                    result.addAll(l2);
                    return result;
                });
            }
        }

        logger.info("End of DataDependencyAnalysis");
    }

    private void buildLinkedEdgeConditions(Pair<Event, RegReader> first_edge_link, List<Pair<RegReader, LinkedEdgeEncodingInfo>> edge_ends, LinkedEdgeEncodingInfo info_builder) {
        final var from = first_edge_link.getLeft();
        final var to = first_edge_link.getRight();
        if (from instanceof PhantomEvent && to instanceof PhantomEvent to_phantom) {
            final var info = edges_to_encode_with_both_phantom.get(first_edge_link);
            info_builder.link_infos().add(info);
            info_builder.phantoms().add(to_phantom);
            final var next_edges = edge_keys_for_phantom_start_edges.get(to_phantom);
            for (var next_edge : next_edges) {
                buildLinkedEdgeConditions(next_edge, edge_ends, info_builder);
            }
            info_builder.link_infos().remove(info_builder.link_infos().size() - 1);
            info_builder.phantoms().remove(info_builder.phantoms().size() - 1);
        } else if (from instanceof PhantomEvent) {
            final var info = edges_to_encode_with_phantom_start.get(first_edge_link);
            info_builder.link_infos().add(info);
            edge_ends.add(Pair.of(first_edge_link.getRight(), LinkedEdgeEncodingInfo.clone(info_builder)));
            info_builder.link_infos().remove(info_builder.link_infos().size() - 1);
        } else if (to instanceof PhantomEvent phantom) {
            final var info = edges_to_encode_with_phantom_end.get(first_edge_link);
            info_builder.link_infos().add(info);
            info_builder.phantoms().add(phantom);
            final var next_edges = edge_keys_for_phantom_start_edges.get(phantom);
            for (var next_edge : next_edges) {
                buildLinkedEdgeConditions(next_edge, edge_ends, info_builder);
            }
            info_builder.link_infos().remove(info_builder.link_infos().size() - 1);
            info_builder.phantoms().remove(info_builder.phantoms().size() - 1);
        } else {
            assert false;
        }
    }

    public record EdgeInfo(boolean is_must, AddrLinkKind link_kind) {}

    public Stream<Pair<Pair<Event, RegReader>, EdgeInfo>> getEdgeInfos() {
        if (!analysis_ran) {
            runAnalysis();
            analysis_ran = true;
        }
        return final_edges.entrySet().stream().map(e -> {
            final var is_must = e.getValue().stream().anyMatch(EncodingInfo::is_must);
            final var link_kind = e.getValue().stream().map(i -> i instanceof EdgeEncodingInfo info ? info.addr_kind() : ((LinkedEdgeEncodingInfo) i).link_infos().stream().map(EdgeEncodingInfo::addr_kind).reduce(AddrLinkKind.NONE, AddrLinkKind::add)).reduce(AddrLinkKind::merge);
            assert link_kind.isPresent();
            return Pair.of(e.getKey(), new EdgeInfo(is_must, link_kind.get()));
        });
    }

    public Stream<Map.Entry<Pair<Event, RegReader>, List<EncodingInfo>>> getFullEdgesToEncode() {
        if (!analysis_ran) {
            runAnalysis();
            analysis_ran = true;
        }
        return final_edges.entrySet().stream();
    }

    public boolean edgeExists(Event e1, RegReader e2) {
        return final_edges.containsKey(Pair.of(e1, e2));
    }

    private void addEvent(BitSet bits, Event event) {
        final var index = event_bit_indices.get(current_thread).get(event);
        bits.set(index);
    }

    private void removeEvent(BitSet bits, Event event) {
        final var index = event_bit_indices.get(current_thread).get(event);
        bits.set(index, false);
    }

    public Stream<Event> eventStreamOfSet(BitSet set, com.dat3m.dartagnan.program.Thread thread) {
        return set.stream().mapToObj(i -> event_bit_indices.get(thread).inverse().get(i));
    }

    private boolean isChunkBorder(Event event) {
        if (event.hasTag(Tag.MEMORY)) return true;
        return event instanceof CondJump jump && !(jump.isGoto() || jump.isDead());
    }

    private void recordEdge(Event from, RegReader to, PathCondition condition, AddrLinkKind edge_kind) {
        final var edge_key = Pair.of(from, to);

        final Map<Pair<Event, RegReader>, EdgeEncodingInfo> edge_encoding_map_to_use;

        if (from instanceof PhantomEvent phantom_start && to instanceof PhantomEvent) {
            edge_encoding_map_to_use = edges_to_encode_with_both_phantom;
            final var edge_list = edge_keys_for_phantom_start_edges.computeIfAbsent(phantom_start, p -> new LinkedHashSet<>());
            edge_list.add(edge_key);
        } else if (from instanceof PhantomEvent phantom) {
            edge_encoding_map_to_use = edges_to_encode_with_phantom_start;
            final var edge_list = edge_keys_for_phantom_start_edges.computeIfAbsent(phantom, p -> new LinkedHashSet<>());
            edge_list.add(edge_key);
        } else if (to instanceof PhantomEvent) {
            edge_encoding_map_to_use = edges_to_encode_with_phantom_end;
        } else {
            edge_encoding_map_to_use = edges_to_encode;
        }

        final var info = edge_encoding_map_to_use.merge(
                edge_key,
                new EdgeEncodingInfo(new ArrayList<>(), edge_kind),
                (i1, i2) -> new EdgeEncodingInfo(i1.conditions(), i1.addr_kind().merge(i2.addr_kind()))
        );
        if (info.conditions().isEmpty() || !info.conditions().get(0).isStructAndCondMust()) {
            info.conditions().add(new PathCondition(condition));
            if (condition.isStructAndCondMust()) {
                info.conditions().removeIf(c -> !c.isStructAndCondMust());
            }
        }
    }

    static final int PHANTOM_NODE_BOUND = 4;

    private void addDependencyEdge(RegReader current_node, RegReader sink, PathCondition accumulated_condition, AddrLinkKind path_link_kind) {
        final var addr_link_map = new HashMap<Register, AddrLinkKind>();
        if (current_node == sink) {
            for (var read : current_node.getRegisterReads()) {
                addr_link_map.merge(read.register(), AddrLinkKind.fromUsageType(read.usageType()), AddrLinkKind::merge);
            }
        }

        final var forbidden_up_unitil_here = (BitSet) accumulated_condition.forbidden().clone();

        final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(current_node);
        for (Register register : writers.getUsedRegisters()) {
            final var reg_writers = writers.ofRegister(register);
            final var may_writers = reg_writers.getMayWriters();
            final var must_writers = reg_writers.getMustWriters();

            final var addr_link_kind = addr_link_map.getOrDefault(register, AddrLinkKind.NONE);
            var new_sink = sink;
            var new_path_link_kind = path_link_kind.add(addr_link_kind);
            var new_accumulated_condition = accumulated_condition;

            final var existing_phantom = phantom_event_map.get(may_writers);
            if (existing_phantom != null) {
                recordEdge(existing_phantom, sink, accumulated_condition, new_path_link_kind);
                continue;
            }

            final var phantom_needed = may_writers.size() > PHANTOM_NODE_BOUND
                    && !registers_with_phantom_events.contains(register)
                    && ((BackwardsReachingDefinitionsAnalysis) definitions).getReaders(may_writers.get(may_writers.size() - 1)).getReaders().size() > PHANTOM_NODE_BOUND;

            if (phantom_needed) {
                registers_with_phantom_events.add(register);
                final var phantom = PhantomEvent.create();
                phantom_event_map.put(may_writers, phantom);
                recordEdge(phantom, sink, accumulated_condition, new_path_link_kind);
                new_sink = phantom;
                new_path_link_kind = AddrLinkKind.NONE;
                new_accumulated_condition = PathCondition.from_size(event_count);
            }

            for (int writer_index = may_writers.size() - 1; writer_index >= 0; writer_index--) {
                final var writer = may_writers.get(writer_index);
                final var is_structurally_must = must_writers.contains(writer);
                var recurse_acc_condition = new_accumulated_condition;

                Event possible_border = writer; // status events are always writers tagged with MEMORY and are chunk borders
                if (writer instanceof ExecutionStatus status && status.doesTrackDep()) {
                    possible_border = status.getStatusEvent();
                }

                final var is_conditionally_must = exec.isImplied(current_node, writer);
                final var is_chunk_border = isChunkBorder(possible_border);

                if (is_chunk_border) {
                    if (is_structurally_must) {
                        recurse_acc_condition = new PathCondition(new_accumulated_condition);
                        recurse_acc_condition.forbidden().and(forbidden_up_unitil_here);
                    }
                    recordEdge(possible_border, new_sink, recurse_acc_condition, new_path_link_kind);
                    addEvent(new_accumulated_condition.forbidden(), writer);
                    continue;
                }

                if (!is_conditionally_must) addEvent(new_accumulated_condition.required(), writer);
                if (is_structurally_must) {
                    recurse_acc_condition = new PathCondition(new_accumulated_condition);
                    recurse_acc_condition.forbidden().and(forbidden_up_unitil_here);
                }

                if (possible_border instanceof RegReader reader) {
                    addDependencyEdge(reader, new_sink, recurse_acc_condition, new_path_link_kind);
                }

                addEvent(new_accumulated_condition.forbidden(), writer);
                if (!is_conditionally_must) removeEvent(new_accumulated_condition.required(), writer);
            }

            accumulated_condition.forbidden().and(forbidden_up_unitil_here);
        }
    }
}
