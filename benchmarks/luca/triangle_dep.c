#include <dat3m.h>
#include <assert.h>

static int global1 = 42;
static int global2 = 69;

int main() {
    int dep = global1;

    if (__VERIFIER_nondet_bool()) {
        int other = dep + 67;
        dep = other;
        other = (dep + dep) / 2;
        dep = global2 + (other - other); // this should be the only non-execution we care about for the overwrites
    }

    global1 = dep;

    assert(global1 < 100);
}
