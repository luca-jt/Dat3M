#include <assert.h>
#include <dat3m.h>
#include <stdlib.h>
#include <pthread.h>

#define N 5


int x = 0;
int y = 0;
int z = 0;

int t1r = 0;
int t2r = 0;

int longDepChain(int input) {
        int update = z; // 0
        for (int i = 0; i < 2*N; i++) {
            if (__VERIFIER_nondet_bool()) {
                input += update;
            }
        }

        return input; // Returns 0, but with a dependency to input (and z)
}

void *thread_1(void* ignore) {
        int r = x;
        y = longDepChain(r) + 1;
        // y = longDepChain(0) + 1 // FAIL under aarch64.cat due to broken dependency

        t1r = r;
}

void *thread_2(void* ignore) {
        int r = y;
        x = longDepChain(r) + 1;

        t2r = r;
}

int main()
{
    pthread_t t1, t2;
    pthread_create(&t1, NULL, thread_1, NULL);
    pthread_create(&t2, NULL, thread_2, NULL);

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    assert(t1r + t2r <= 1);
}
