/*
  cuda.cu - Image manipulations using CUDA
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdio.h>
#include <stdlib.h>
#include <opencv2/opencv.hpp>
#include "common.h"


#pragma mark Transformation Types

int const CUDA_SWAP   = 0;
int const CUDA_GRAY   = 1;
int const CUDA_BLUR   = 2;
int const CUDA_EMBOSS = 3;


#pragma mark Macros

// Length of an array
#define ARRAY_LENGTH(a) ((sizeof(a) > 0) ? sizeof(a) / sizeof(a[0]) : 0)

// Check if CUDA function was executed successfully
#define CUDA_CHECK(call) {                                                                                \
  const cudaError_t e = call;                                                                             \
  if (e != cudaSuccess) {                                                                                 \
    printf("\nCUDA error: %s:%d, code: %d, reason: %s\n", __FILE__, __LINE__, e, cudaGetErrorString(e));  \
    exit(2);                                                                                              \
  }                                                                                                       \
}


#pragma mark Kernels

__global__ void kernel_swap(uint32_t *in, uint32_t *out, uint32_t w, uint32_t h) {
  int idx = blockIdx.y * w + blockIdx.x;

  // Check if thread index is no longer within input array
  if (ARRAY_LENGTH(in) >= idx) { return; }

  out[idx] = RGBA(RED(in[idx]), BLUE(in[idx]), GREEN(in[idx]), ALPHA(in[idx]));
}

__global__ void kernel_gray(uint32_t *in, uint32_t *out, uint32_t w, uint32_t h) {
  int idx = blockIdx.y * w + blockIdx.x;

  // Check if thread index is no longer within input array
  if (ARRAY_LENGTH(in) >= idx) { return; }

  uint8_t gray = (0.21 * RED(in[idx])) + (0.72 * GREEN(in[idx])) + (0.07 * BLUE(in[idx]));

  out[idx] = RGBA(gray, gray, gray, ALPHA(in[idx]));
}

__global__ void kernel_blur(uint32_t *in, uint32_t *out, uint32_t w, uint32_t h, uint8_t area) {
  int idx = blockIdx.y * w + blockIdx.x;

  // Check if thread index is no longer within input array
  if (ARRAY_LENGTH(in) >= idx) { return; }

  uint32_t min_x      = blockIdx.x < area ? 0 : blockIdx.x - area;
  uint32_t min_y      = blockIdx.y < area ? 0 : blockIdx.y - area;
  uint32_t max_x      = (blockIdx.x + area) >= w ? w : blockIdx.x + area;
  uint32_t max_y      = (blockIdx.y + area) >= h ? h : blockIdx.y + area;
  uint32_t num_pixels = 0;
  uint32_t red_sum    = 0;
  uint32_t green_sum  = 0;
  uint32_t blue_sum   = 0;
  uint32_t alpha_sum  = 0;
  uint32_t i          = 0;

  for(int x = min_x; x < max_x; x += 1) {
    for(int y = min_y; y < max_y; y += 1) {
      i = y * w + x;

      num_pixels += 1;
      red_sum    += RED(in[i]);
      green_sum  += GREEN(in[i]);
      blue_sum   += BLUE(in[i]);
      alpha_sum  += ALPHA(in[i]);
    }
  }

  out[idx] = RGBA((red_sum / num_pixels), (green_sum / num_pixels), (blue_sum / num_pixels), (alpha_sum / num_pixels));
}

__global__ void kernel_emboss(uint32_t *in, uint32_t *out, uint32_t w, uint32_t h) {
  if (blockIdx.y < 1 || blockIdx.x < 1) { return; }

  int idx     = blockIdx.y * w + blockIdx.x;
  int idx_ref = (blockIdx.y - 1) * w + (blockIdx.x - 1);

  // Check if thread index is no longer within input array
  if (ARRAY_LENGTH(in) >= idx) { return; }
  if (ARRAY_LENGTH(in) >= idx_ref) { return; }

  int diffs[] = {
    (RED(in[idx_ref]) - RED(in[idx])),
    (GREEN(in[idx_ref]) - GREEN(in[idx])),
    (BLUE(in[idx_ref]) - BLUE(in[idx]))
  };

  int diff = diffs[0];
  if ((diffs[1] < 0 ? diffs[1] * -1 : diffs[1]) > diff) { diff = diffs[1]; }
  if ((diffs[2] < 0 ? diffs[2] * -1 : diffs[2]) > diff) { diff = diffs[2]; }

  int gray = 128 + diff;
  if (gray > 255) { gray = 255; }
  if (gray < 0) { gray = 0; }

  out[idx] = RGBA(gray, gray, gray, ALPHA(in[idx]));
}


#pragma mark CUDA wrapper

// Output CUDA information
static void showCudaInfo() {
  cudaDeviceProp prop;
  CUDA_CHECK(cudaGetDeviceProperties(&prop, 0));

  printf("CUDA INFORMATION\n================\n");
  printf("Name: %s\n", prop.name);
  printf("Total Memory: %u Bytes\n", prop.totalGlobalMem);
  printf("Max. Threads Per Block: %d\n", prop.maxThreadsPerBlock);
  printf("Clock Rate: %d kHz\n", prop.clockRate);
  printf("Multiprocessors: %d\n", prop.multiProcessorCount);
  printf("Concurrent Kernels: %d\n", prop.concurrentKernels);
}

// Wrapper for all CUDA kernels
result cuda(int type, uint32_t width, uint32_t height, uint32_t *data, uint8_t area) {
  // Show CUDA infos
  #ifndef GNUPLOT_MODE
  showCudaInfo();
  #endif

  size_t buffer_size = width * height * sizeof(uint32_t);
  uint32_t *dev_in, *dev_out;

  // Allocate memory on device
  CUDA_CHECK(cudaMalloc((void **) &dev_in, buffer_size));
  CUDA_CHECK(cudaMalloc((void **) &dev_out, buffer_size));

  // Copy image data to device
  CUDA_CHECK(cudaMemcpy(dev_in, data, buffer_size, cudaMemcpyHostToDevice));

  // Measure execution time
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  dim3 threads(8, 8);
  dim3 blocks((width / threads.x + 1), (height / threads.y + 1));

  cudaEventRecord(start);

  switch(type) {
    case CUDA_SWAP:
      kernel_swap<<<blocks, threads>>>(dev_in, dev_out, width, height);
      break;

    case CUDA_GRAY:
      kernel_gray<<<blocks, threads>>>(dev_in, dev_out, width, height);
      break;

    case CUDA_BLUR:
      kernel_blur<<<blocks, threads>>>(dev_in, dev_out, width, height, area);
      break;

    case CUDA_EMBOSS:
      kernel_emboss<<<blocks, threads>>>(dev_in, dev_out, width, height);
      break;
  }

  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  float runtime = 0;
  cudaEventElapsedTime(&runtime, start, stop);

  // Copy transformed image data from device
  CUDA_CHECK(cudaMemcpy(data, dev_out, buffer_size, cudaMemcpyDeviceToHost));
  CUDA_CHECK(cudaFree(dev_in));
  CUDA_CHECK(cudaFree(dev_out));

  // Terminate CUDA device usage
  CUDA_CHECK(cudaDeviceReset());

  struct result res;
  res.code    = RES_ARRAY;
  res.runtime = (long) (runtime * 1000);

  return res;
}


#pragma mark Transformations

result swap(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  return cuda(CUDA_SWAP, width, height, data, 0);
}

result gray(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  return cuda(CUDA_GRAY, width, height, data, 0);
}

result blur(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data, uint8_t area) {
  return cuda(CUDA_BLUR, width, height, data, area);
}

result emboss(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  return cuda(CUDA_EMBOSS, width, height, data, 0);
}
