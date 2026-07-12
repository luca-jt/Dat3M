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

    public record EdgeEncodingInfo(List<PathCondition> conditions, AddrLinkKind addr_kind) {}

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

            for (RegReader possible_sink : reverse(sink_event_list)) {
                if (!isChunkBorder(possible_sink)) continue;
                if (!visited_sinks.add(possible_sink)) continue;
                addDependencyEdge(possible_sink, possible_sink, PathCondition.from_size(event_count), AddrLinkKind.NONE);
            }
        }

        edges_to_encode.entrySet().stream().filter(e -> !e.getValue().conditions().isEmpty()).forEach(e -> {
            final var info = e.getValue();

            if (info.conditions().stream().anyMatch(PathCondition::isStructAndCondMust)) {
                info.conditions().clear();
            }
        });

        logger.info("End of DataDependencyAnalysis");
    }

    public Stream<Map.Entry<Pair<Event, RegReader>, EdgeEncodingInfo>> getEdgesToEncode() {
        if (!analysis_ran) {
            runAnalysis();
            analysis_ran = true;
        }
        return edges_to_encode.entrySet().stream();
    }

    public boolean edgeExists(Event e1, RegReader e2) {
        return edges_to_encode.containsKey(Pair.of(e1, e2));
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
            final var may_writers = writers.ofRegister(register).getMayWriters();
            final var addr_link_kind = addr_link_map.getOrDefault(register, AddrLinkKind.NONE);

            for (int writer_index = may_writers.size() - 1; writer_index >= 0; writer_index--) {
                final var writer = may_writers.get(writer_index);

                Event possible_border = writer; // status events are always writers tagged with MEMORY and are chunk borders
                if (writer instanceof ExecutionStatus status && status.doesTrackDep()) {
                    possible_border = status.getStatusEvent();
                }

                final var is_conditionally_must = exec.isImplied(current_node, writer);

                final var is_chunk_border = isChunkBorder(possible_border);

                if (is_chunk_border) {
                    final var info = edges_to_encode.merge(
                            Pair.of(possible_border, sink),
                            new EdgeEncodingInfo(new ArrayList<>(), path_link_kind.add(addr_link_kind)),
                            (i1, i2) -> new EdgeEncodingInfo(i1.conditions(), i1.addr_kind().merge(i2.addr_kind()))
                    );
                    info.conditions().add(new PathCondition(accumulated_condition));
                    addEvent(accumulated_condition.forbidden(), writer);
                    continue;
                } else if (!is_conditionally_must) {
                    addEvent(accumulated_condition.required(), writer);
                }

                if (possible_border instanceof RegReader reader) {
                    addDependencyEdge(reader, sink, accumulated_condition, path_link_kind.add(addr_link_kind));
                }

                addEvent(accumulated_condition.forbidden(), writer);
                if (!is_conditionally_must) removeEvent(accumulated_condition.required(), writer);
            }

            accumulated_condition.forbidden().and(forbidden_up_unitil_here);
        }
    }
}
