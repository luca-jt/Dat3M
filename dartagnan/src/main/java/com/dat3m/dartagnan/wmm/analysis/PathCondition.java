package com.dat3m.dartagnan.wmm.analysis;

import java.util.BitSet;

public record PathCondition(BitSet required, BitSet forbidden) {
    public boolean isStructAndCondMust() {
        return required.isEmpty() && forbidden.isEmpty();
    }

    public PathCondition(PathCondition other) {
        this((BitSet) other.required.clone(), (BitSet) other.forbidden.clone());
    }

    public static PathCondition from_size(int size) {
        return new PathCondition(new BitSet(size), new BitSet(size));
    }
}
