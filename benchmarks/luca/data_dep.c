#include <dat3m.h>
#include <assert.h>

static int global = 42;

int main() {
    int dep = global;

    int case_distinction;
    int other = __VERIFIER_nondet_int();

    if (__VERIFIER_nondet_bool()) {
        case_distinction = dep * (dep - dep);
    } else {
        case_distinction = 0;
    }

    global = (case_distinction + case_distinction) / 2;

    assert(global == 0);
}
