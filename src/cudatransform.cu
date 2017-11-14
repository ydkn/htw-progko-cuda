/*
  cudatransform.cu - Image manipulations using CUDA
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/


#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>
#include "pnglite.h"


extern const char *__progname;


#pragma mark Image Helper Stuff

// Representation image
struct Image {
  png_t    png;
  uint32_t *pixels;
  size_t   number_of_pixels;
  uint     width;
  uint     height;
};

// Access red, green, blue, and alpha component values in a 32-bit unsigned RGBA pixel value.
#define ALPHA(pixel) ((pixel)>>24)
#define BLUE(pixel)  (((pixel)>>16)&0xFF)
#define GREEN(pixel) (((pixel)>>8)&0xFF)
#define RED(pixel)   ((pixel)&0xFF)

// Encode a 32-bit unsigned RGBA value from individual red, green, blue, and alpha component values.
#define RGBA(r,g,b,a) ((((a) << 24)) | (((b) << 16)) | (((g) << 8)) | ((r)))


#pragma mark CUDA Kernels

// Swap green and blue
__global__ void kernel_swap_green_blue(uint32_t *in, uint32_t *out, int w, int h){
  int idx = blockIdx.y * w + blockIdx.x;

  out[idx] = RGBA(RED(in[idx]), BLUE(in[idx]), GREEN(in[idx]), ALPHA(in[idx]));
}

// Transform image into gray scale
__global__ void kernel_gray(uint32_t *in, uint32_t *out, int w, int h){
  int idx = blockIdx.y * w + blockIdx.x;

  uint8_t gray = (0.21 * RED(in[idx])) + (0.72 * GREEN(in[idx])) + (0.07 * BLUE(in[idx]));

  out[idx] = RGBA(gray, gray, gray, ALPHA(in[idx]));
}

// Blur image
__global__ void kernel_blur(uint32_t *in, uint32_t *out, int w, int h) {
  int idx = blockIdx.y * w + blockIdx.x;

  // TODO implement

  out[idx] = RGBA(RED(in[idx]), GREEN(in[idx]), BLUE(in[idx]), ALPHA(in[idx]));
}

// Transform image with emboss
__global__ void kernel_emboss(uint32_t *in, uint32_t *out, int w, int h) {
  if (blockIdx.y < 1 || blockIdx.x < 1) { return; }

  int idx     = blockIdx.y * w + blockIdx.x;
  int idx_ref = (blockIdx.y - 1) * w + (blockIdx.x - 1);

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


#pragma mark Helper Methods

// Terminate program with message
void terminate(const char *fmt, ...) {
  va_list args;

  va_start(args, fmt);
  vfprintf(stderr, fmt, args);
  va_end(args);

  exit(1);
}

// Allocate a buffer large enough to store pixel data for given image.
uint32_t *alloc_image_buffer(Image *img) {
  return (uint32_t *) malloc(img->number_of_pixels * sizeof(uint32_t));
}

// Read an image from a file
static Image *read_image(const char *filename) {
  Image *img = (Image *) malloc(sizeof(Image));

  if (png_open_file_read(&img->png, filename) != PNG_NO_ERROR) {
    terminate("Couldn't open image\n");
  }

  // Number of pixels
  img->width            = img->png.width;
  img->height           = img->png.height;
  img->number_of_pixels = img->png.width * img->png.height;

  if (img->png.color_type != PNG_TRUECOLOR_ALPHA) {
    terminate("Only true color alpha images supported\n");
  }

  img->pixels = alloc_image_buffer(img);

  if (png_get_data(&img->png, (unsigned char *) img->pixels) != PNG_NO_ERROR) {
    terminate("Could not read image data\n");
  }

  return img;
}

// Save a transformed image.
static void save_image(const char *filename, uint32_t *img_data, const Image *orig_img) {
  png_t out;

  if (png_open_file_write(&out, filename) != PNG_NO_ERROR) {
    terminate("couldn't open image to save\n");
  }

  if (png_set_data(&out, orig_img->png.width, orig_img->png.height, orig_img->png.depth,
                   orig_img->png.color_type, (unsigned char *)img_data) != PNG_NO_ERROR) {
    terminate("Could not save image data\n");
  }

  png_close_file(&out);
}


#pragma mark Info Outputs

// Output CUDA information
static void showCudaInfo() {
  cudaDeviceProp prop;
  cudaGetDeviceProperties(&prop, 0);
  printf("CUDA INFORMATION\n================\n");
  printf("Name: %s\n", prop.name);
  printf("Total Memory: %u Bytes\n", prop.totalGlobalMem);
  printf("Max. Threads Per Block: %d\n", prop.maxThreadsPerBlock);
  printf("Clock Rate: %d kHz\n", prop.clockRate);
  printf("Multiprocessors: %d\n", prop.multiProcessorCount);
  printf("Concurrent Kernels: %d\n", prop.concurrentKernels);
}

// Output image information
static void showImageInfo(const Image *img) {
  printf("\nIMAGE INFORMATION\n================\n");
  printf("Width: %u\n", img->width);
  printf("Height: %u\n", img->height);
  printf("Total Pixels: %u\n", img->number_of_pixels);
}


#pragma mark main

int main(int argc, char **argv) {
  if (argc != 4) {
    terminate("Usage: %s <swap|gray|blur|emboss> <infile> <outfile>\n", __progname);
  }

  // Load image
  png_init(0, 0);

  Image    *img          = read_image(argv[2]);
  uint32_t *img_data     = img->pixels;
  uint32_t *out_img_data = (uint32_t *) alloc_image_buffer(img);

  // Show CUDA infos
  showCudaInfo();

  // Show image infos
  showImageInfo(img);

  // Initialize/allocate buffers
  size_t buffer_size = img->number_of_pixels * sizeof(uint32_t);
  uint32_t *dev_imgdata, *dev_imgdata_out;
  cudaMalloc((void **) &dev_imgdata, buffer_size);
  cudaMalloc((void **) &dev_imgdata_out, buffer_size);

  // Copy image data to device
  cudaMemcpy(dev_imgdata, img_data, buffer_size, cudaMemcpyHostToDevice);
  dim3 grid(img->width, img->height);

  // Switch transformation type
  if (strcmp(argv[1], "swap") == 0) {
    kernel_swap_green_blue<<<grid, 1>>>(dev_imgdata, dev_imgdata_out, img->width, img->height);
  } else if (strcmp(argv[1], "gray") == 0) {
    kernel_gray<<<grid, 1>>>(dev_imgdata, dev_imgdata_out, img->width, img->height);
  } else if (strcmp(argv[1], "blur") == 0) {
    kernel_blur<<<grid, 1>>>(dev_imgdata, dev_imgdata_out, img->width, img->height);
  } else if (strcmp(argv[1], "emboss") == 0) {
    kernel_emboss<<<grid, 1>>>(dev_imgdata, dev_imgdata_out, img->width, img->height);
  } else {
    terminate("\nUnsupported Transformation: %s\n", argv[1]);
  }

  // Copy transformed image data from device
  cudaMemcpy(out_img_data, dev_imgdata_out, buffer_size, cudaMemcpyDeviceToHost);

  // Save image to disk and close file handle
  save_image(argv[3], out_img_data, img);
  png_close_file(&img->png);

  printf("\nSaved Transformed Image: %s\n", argv[3]);

  // Cleanup memory
  free(img->pixels);
  free(img);
  free(out_img_data);

  return 0;
}
