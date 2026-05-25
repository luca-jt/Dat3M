#include <dat3m.h>
#include <assert.h>

static int global1 = 42;
static int global2 = 42;

int main() {
    int dep = global1;

    int case_distinction = 67;

    if (__VERIFIER_nondet_bool()) {
        case_distinction = dep * (dep - dep);
    } else if (__VERIFIER_nondet_bool()) {
        case_distinction = 0;
        if (__VERIFIER_nondet_bool()) {
            case_distinction = 69 * (dep - dep);
        }
    } else {
        case_distinction = dep - dep;
    }

    global2 = (case_distinction + case_distinction) / 2;

    assert(global2 == 0);
}
