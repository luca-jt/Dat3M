#include <dat3m.h>
#include <assert.h>
#include <stdatomic.h>

static atomic_int global1 = 69;
static atomic_int global2 = 42;

int main() {
    int x = atomic_exchange(&global1, 42);

    if (__VERIFIER_nondet_bool()) {
        x = atomic_exchange(&global2, 69 - x);
    }

    x = atomic_exchange(&global1, x);

    assert(x < 100);
}
