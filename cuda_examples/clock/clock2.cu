/*
EXAMPLE SOURCE : 
https://forums.developer.nvidia.com/t/reading-globaltimer-register-or-calling-clock-clock64-in-loop-prevent-concurrent-kernel-execution/48600/8
https://docs.nvidia.com/cuda/parallel-thread-execution/index.html#special-registers-clock64
https://docs.nvidia.com/cuda/inline-ptx-assembly/index.html

generating Asm PTX code
https://developer.nvidia.com/blog/cuda-pro-tip-view-assembly-code-correlation-nsight-visual-studio-edition/
https://stackoverflow.com/questions/20482686/how-to-get-the-assembly-code-of-a-cuda-kernel
$ nvcc -ptx -o kernel.ptx kernel.cu

.func  (.param .b64 func_retval0) clock64(

)
{
        .reg .b64       %rd<3>;


        // inline asm
        mov.u64         %rd1, %clock64;
        // inline asm
        mov.b64         %rd2, %rd1;
        st.param.b64    [func_retval0+0], %rd2;
        ret;
}





COMPILATION:
/usr/local/cuda-10.2/bin/nvcc -ccbin g++ -I../common/inc  -m64 -g -G    -gencode arch=compute_30,code=sm_30 -gencode arch=compute_30,code=compute_30 -o clock2  clock2.cu
/usr/local/cuda-10.2/bin/nvcc -ccbin g++ -I../common/inc  -m64 -g -G    -gencode arch=compute_72,code=sm_72 -gencode arch=compute_72,code=compute_72 -o clock2  clock2.cu

THIS EXAMPLE WORKS, WITH SOME LITTLE EXTRA TIME
*/
#include <stdio.h>

#define DELAY_VAL 5000000000ULL // about 5 secs

__global__ void child(){

    unsigned long long start = clock64();
    for(long long int i=0;i<10000000;i++);
    //while (clock64()< start+DELAY_VAL);
    
}

int main(int argc, char* argv[])
{
    cudaStream_t st1;
    cudaStreamCreate(&st1);

    clock_t ck_start = clock();
    child<<<1,1,0,st1>>>();
    cudaDeviceSynchronize();

    printf ("Kernel: %ld clicks.\n", clock()-ck_start);
    return 0;
}
