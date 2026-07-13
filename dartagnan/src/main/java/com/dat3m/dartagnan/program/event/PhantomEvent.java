package com.dat3m.dartagnan.program.event;

import com.dat3m.dartagnan.expression.Expression;
import com.dat3m.dartagnan.expression.ExpressionVisitor;
import com.dat3m.dartagnan.program.Function;
import com.dat3m.dartagnan.program.Program;
import com.dat3m.dartagnan.program.Register;
import com.dat3m.dartagnan.program.Thread;
import com.dat3m.dartagnan.program.event.metadata.Metadata;
import com.dat3m.dartagnan.verification.Context;

import java.util.Collection;
import java.util.List;
import java.util.Set;

public record PhantomEvent(int generation) implements Event, RegReader {
    static int generation_counter = 1;

    public static PhantomEvent create() {
        final var gen = generation_counter;
        generation_counter += 1;
        return new PhantomEvent(gen);
    }

    @Override
    public int getGlobalId() {
        return -1;
    }

    @Override
    public void setGlobalId(int id) {}

    @Override
    public int getLocalId() {
        return -1;
    }

    @Override
    public void setLocalId(int id) {}

    @Override
    public void copyAllMetadataFrom(Event other) {}

    @Override
    public void copyMetadataFrom(Event other, Class<? extends Metadata> metadataClass) {}

    @Override
    public boolean hasMetadata(Class<? extends Metadata> metadataClass) {
        return false;
    }

    @Override
    public <T extends Metadata> T getMetadata(Class<T> metadataClass) {
        return null;
    }

    @Override
    public <T extends Metadata> T setMetadata(T metadata) {
        return null;
    }

    @Override
    public boolean hasEqualMetadata(Event other, Class<? extends Metadata> metadataClass) {
        return false;
    }

    @Override
    public Set<String> getTags() {
        return Set.of();
    }

    @Override
    public boolean hasTag(String tag) {
        return false;
    }

    @Override
    public void addTags(Collection<? extends String> tags) {}

    @Override
    public void addTags(String... tags) {}

    @Override
    public void removeTags(Collection<? extends String> tags) {}

    @Override
    public void removeTags(String... tags) {}

    @Override
    public Function getFunction() {
        return null;
    }

    @Override
    public void setFunction(Function function) {}

    @Override
    public Thread getThread() {
        return null;
    }

    @Override
    public Event getSuccessor() {
        return null;
    }

    @Override
    public Event getPredecessor() {
        return null;
    }

    @Override
    public List<Event> getSuccessors() {
        return List.of();
    }

    @Override
    public List<Event> getPredecessors() {
        return List.of();
    }

    @Override
    public void setSuccessor(Event event) {}

    @Override
    public void setPredecessor(Event event) {}

    @Override
    public void detach() {}

    @Override
    public void forceDelete() {}

    @Override
    public boolean tryDelete() {
        return false;
    }

    @Override
    public void insertAfter(Event toBeInserted) {}

    @Override
    public void insertBefore(Event toBeInserted) {}

    @Override
    public void replaceBy(Event replacement) {}

    @Override
    public void insertAfter(Iterable<? extends Event> toBeInserted) {}

    @Override
    public void insertBefore(Iterable<? extends Event> toBeInserted) {}

    @Override
    public void replaceBy(Iterable<? extends Event> replacement) {}

    @Override
    public Set<EventUser> getUsers() {
        return Set.of();
    }

    @Override
    public boolean registerUser(EventUser user) {
        return false;
    }

    @Override
    public boolean removeUser(EventUser user) {
        return false;
    }

    @Override
    public void replaceAllUsages(Event replacement) {}

    @Override
    public int compareTo(Event e) {
        return 0;
    }

    @Override
    public Event getCopy() {
        return null;
    }

    @Override
    public <T> T accept(EventVisitor<T> visitor) {
        return null;
    }

    @Override
    public void runLocalAnalysis(Program program, Context context) {}

    @Override
    public boolean cfImpliesExec() {
        return false;
    }

    @Override
    public Set<Register.Read> getRegisterReads() {
        return Set.of();
    }

    @Override
    public void transformExpressions(ExpressionVisitor<? extends Expression> exprTransformer) {}
}
