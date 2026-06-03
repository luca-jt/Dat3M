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
import com.dat3m.dartagnan.wmm.utils.graph.mutable.MapEventGraph;

import java.util.*;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.reverse;


public class DataDependencyChunkAnalysis {
    protected final VerificationTask task;
    protected final Context analysisContext;
    protected final ExecutionAnalysis exec;
    protected final ReachingDefinitionsAnalysis definitions;

    private final MapEventGraph edges_to_encode = new MapEventGraph();
    private final HashMap<RegReader, LinkedHashMap<Register, ArrayList<RegWriter>>> reverse_edge_map;
    private final HashMap<Event, Boolean> chunk_borders = new HashMap<>();

    public DataDependencyChunkAnalysis(VerificationTask t, Context context) {
        task = checkNotNull(t);
        analysisContext = context;
        exec = context.requires(ExecutionAnalysis.class);
        definitions = context.requires(ReachingDefinitionsAnalysis.class);
        reverse_edge_map = new HashMap<>();

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
                for (RegWriter writer : reverse(reg.getMayWriters())) {
                    addDependencyEdge(writer, possible_sink, visited_events);
                }
            }
        }

        final var reverse_edges = edges_to_encode.getInMap();

        for (var entry : reverse_edges.entrySet()) {
            final RegReader reader = (RegReader) entry.getKey();
            final var writers = entry.getValue();
            var writer_map = reverse_edge_map.computeIfAbsent(reader, r -> new LinkedHashMap<>());

            final var other_borders = writers.stream().sorted(Comparator.reverseOrder()).toList(); // reverse program order
            for (Event border : other_borders) {
                final RegWriter casted = (RegWriter) border; // cast is fine here
                var writer_set = writer_map.computeIfAbsent(casted.getResultRegister(), r -> new ArrayList<>());
                writer_set.add(casted);
            }
        }
    }

    public boolean isPossibleCunkBorder(Event event) {
        return chunk_borders.computeIfAbsent(event, e -> {
            if (e.hasTag(Tag.NO_CARRY_DEPS)) return false;
            if (e.hasTag(Tag.MEMORY)) return true;
            if (e instanceof CondJump) return true; // is not writing anyways, so these will only be sinks
            if (e instanceof ExecutionStatus) return true; // For the edges to status events
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

    public Set<Map.Entry<RegReader, LinkedHashMap<Register, ArrayList<RegWriter>>>> getReverseReaderEntries() {
        return reverse_edge_map.entrySet();
    }

    public boolean hasNoEdgesToEncode() {
        return edges_to_encode.isEmpty();
    }

    private void addDependencyEdge(RegWriter start, RegReader end_border, HashSet<Event> visited_events) {
        RegReader new_end_border = end_border;

        if (isPossibleCunkBorder(start)) {
            final var path_found = edges_to_encode.contains(start, end_border);
            if (!path_found) {
                edges_to_encode.add(start, end_border);
            }

            if (start instanceof RegReader reader) {
                new_end_border = reader;
            }
            visited_events.add(start);
        }

        if (start instanceof RegReader reader) {
            final ReachingDefinitionsAnalysis.Writers writers = definitions.getWriters(reader);
            for (Register register : writers.getUsedRegisters()) {
                final ReachingDefinitionsAnalysis.RegisterWriters reg = writers.ofRegister(register);
                for (RegWriter writer : reverse(reg.getMayWriters())) {
                    addDependencyEdge(writer, new_end_border, visited_events);
                }
            }
        }
    }
}
