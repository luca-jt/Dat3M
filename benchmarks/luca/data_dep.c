#include <dat3m.h>
#include <assert.h>

static int global = 42;

int main() {
    int *ref = &global;

    int case_distinction;
    int other = __VERIFIER_nondet_int();

    if (__VERIFIER_nondet_bool()) {
        case_distinction = *ref * 0;
    } else {
        case_distinction = 69;
    }

    int phi = (case_distinction + case_distinction) / 2;

    int first_use = other + 3 * phi;
    int second_use = other + 4 * phi;

    int y = *ref;

    assert(y == 42);
    assert(first_use == second_use - phi);
}
