package com.dat3m.dartagnan.wmm.analysis;

import com.dat3m.dartagnan.program.event.Event;

import java.util.HashSet;
import java.util.Set;

public record PathCondition(Set<Event> required, Set<Event> forbidden) {
    public boolean isStructAndCondMust() {
        return required.isEmpty() && forbidden.isEmpty();
    }

    public PathCondition(PathCondition other) {
        this(new HashSet<>(other.required), new HashSet<>(other.forbidden));
    }
}
