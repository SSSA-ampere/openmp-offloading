/*
EXAMPLE SOURCE : 
https://forums.developer.nvidia.com/t/reading-globaltimer-register-or-calling-clock-clock64-in-loop-prevent-concurrent-kernel-execution/48600/8

COMPILATION:
/usr/local/cuda-10.2/bin/nvcc -ccbin g++ -I../common/inc  -m64 -g -G    -gencode arch=compute_30,code=sm_30 -gencode arch=compute_30,code=compute_30 -o clock2  clock2.cu
/usr/local/cuda-10.2/bin/nvcc -ccbin g++ -I../common/inc  -m64 -g -G    -gencode arch=compute_72,code=sm_72 -gencode arch=compute_72,code=compute_72 -o clock2  clock2.cu

THIS EXAMPLE WORKS, WITH SOME LITTLE EXTRA TIME
*/
#include <stdio.h>

#define DELAY_VAL 5000000000ULL // about 5 secs
/*
long milliseconds()
{
    long            ms; // Milliseconds
    time_t          s;  // Seconds
    struct timespec spec;

    clock_gettime(CLOCK_MONOTONIC, &spec);

    s  = spec.tv_sec;
    ms = round(spec.tv_nsec / 1.0e6); // Convert nanoseconds to milliseconds
    return ms + s *1000;
}
*/

__global__ void child(){

    unsigned long long start = clock64();
    //for(long long int i=0;i<DELAY_VAL;i++);
    while (clock64()< start+DELAY_VAL);
    
}

int main(int argc, char* argv[]){

    cudaStream_t st1, st2;
    cudaStreamCreate(&st1);
    cudaStreamCreate(&st2);

    clock_t ck_start = clock();
    //long start = milliseconds();
    //long now = 0;
    child<<<1,1,0,st1>>>();
    /*
    
        printf("running double kernel\n");
        while ( now < start + DELAY_VAL) {
            now = milliseconds();
        }
        printf("host finishing ...\n");
    */
    //parent<<<1,1,0,st2>>>();
    cudaDeviceSynchronize();
    //printf ("Elapsed: %ld clicks.\n",milliseconds()-start);
    printf ("Kernel: %ld clicks.\n", clock()-ck_start);
    return 0;
}
