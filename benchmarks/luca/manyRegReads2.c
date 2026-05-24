#include <assert.h>
#include <dat3m.h>

#define N 100

int main()
{
    int r1 = 0;
    for (int i = 0; i < N+1; i++) {
        if (__VERIFIER_nondet_bool()) {
            r1 += i;
        }
    }

    //int temp = (r1 + r1) / 2;

    int r2 = 0;
    for (int i = 0; i < N; i++) {
        if (__VERIFIER_nondet_bool()) {
            r2 += r1;
            //r2 += temp;
        }
    }

    assert(r2 <= N*(N*(N+1))/2);
}
