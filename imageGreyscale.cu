#include "reference_calc.cpp"
#include "utils.h"
#include <stdio.h>

__global__
void rgba_to_greyscale(const uchar4* const rgbaImage,
                       unsigned char* const greyImage,
                       int numRows, int numCols)
{
  for(int r = 0; r < numRows; ++r){
    for(int c = 0; c < numCols; ++c){
        uchar4 rgba = rgbaImage[r * numCols + c];
        float channelSum = .299f * rgba.x + .587f * rgba.y + .114f * rgba.z;
        greyImage[r * numCols + c] = channelSum;
    }
}
}

void your_rgba_to_greyscale(const uchar4 * const h_rgbaImage, uchar4 * const d_rgbaImage,
                            unsigned char* const d_greyImage, size_t numRows, size_t numCols)
{
  int numDevices, ThreadsPerBlock;
  //Stored the number of devices on GPU side
  cudaDeviceProp prop;
  cudaGetDeviceCount(&numDevices);
  
  /*Looped through each device and determined the minmum number of threads per block
  assuming both devices would be used. */

  for(int i = 0; i < numDevices; i++){
    cudaGetDeviceProperties(&prop, i);
    if (prop.maxThreadsPerBlock < ThreadsPerBlock){
     ThreadsPerBlock = prop.maxThreadsPerBlock;
    }
  }
  printf("Num devices: %d\n", numDevices);
  printf("Min Threads per block: %d\n", ThreadsPerBlock);
  
  //Called the kernel function 
  const dim3 blockSize(ThreadsPerBlock);
  const dim3 gridSize(numRows * numCols / ThreadsPerBlock);
  rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, numRows, numCols);
  
  cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());
}
