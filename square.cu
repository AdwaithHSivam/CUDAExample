#include <iostream>

__global__
void square(const float *A, float *B, int numElements)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < numElements)
    {
        B[i] = A[i] * A[i];
    }
}

int main(void)
{

    int numElements = 50000;
    size_t size = numElements * sizeof(float);
    std::cout << "[Vector addition of " <<  numElements << " elements]\n";

    float *h_A = new float[size];
    float *h_B = new float[size];

    for (int i = 0; i < numElements; ++i)
    {
        h_A[i] = rand()/(float)RAND_MAX;
    }



    float *d_A, *d_B;
    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);

    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 1024;
    int blocksPerGrid =(numElements + threadsPerBlock - 1) / threadsPerBlock;
    std::cout << "CUDA kernel launch with " << blocksPerGrid 
                << " blocks of " << threadsPerBlock << " threads\n";
    
    square<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, numElements);

    cudaDeviceSynchronize();//wait for all threads to be finished

    cudaMemcpy(h_B, d_B, size, cudaMemcpyDeviceToHost);




    for (int i = 0; i < numElements; ++i)
    {
        if (fabs(h_A[i] * h_A[i] - h_B[i]) > 1e-5)
        {
            std::cerr << "Result verification failed at element " << i << "!\n";
            exit(EXIT_FAILURE);
        }
    }

    std::cout << "Test PASSED\n";
    cudaFree(d_A);
    cudaFree(d_B);

    delete [] h_A;
    delete [] h_B;

    std::cout << "Done\n";
    return 0;
}

