/*
  cudatransform.cu - Image manipulations using CUDA
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/time.h>
#include <opencv2/opencv.hpp>
#include "common.h"

using namespace cv;


#pragma mark Helper Methods

// Terminate program with message
void term_msg(const char *fmt, ...) {
  va_list args;

  va_start(args, fmt);
  vfprintf(stderr, fmt, args);
  va_end(args);

  exit(1);
}


#pragma mark transformations

extern result swap(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data);
extern result gray(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data);
extern result blur(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data, uint8_t area);
extern result emboss(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data);


#pragma mark main

extern const char *__progname;

int main(int argc, char **argv) {
  if (argc < 4) {
    term_msg("Usage: %s <swap|gray|blur|emboss> <infile> <outfile> (<area>)\n", __progname);
  }

  Mat raw_image = imread(argv[2], CV_LOAD_IMAGE_UNCHANGED);

  if (!raw_image.data) {
    term_msg("Unable to load image: %s\n", argv[2]);
  } else {
    #ifndef GNUPLOT_MODE
    printf("Using image: %s\n", argv[2]);
    #endif
  }

  // convert image/matrix to a plain 2-dim array to allow passing same input to all functions
  uint32_t *image = (uint32_t *) malloc((raw_image.rows * raw_image.cols) * sizeof(uint32_t));

  for (int i = 0; i < raw_image.rows; i++) {
    for (int j = 0; j < raw_image.cols; j++) {
      uint32_t raw_index = (i * raw_image.cols + j) * 4;
      uint32_t index     = (i * raw_image.cols) + j;

      // construct single integer value representing all 4 color channels
      image[index] = RGBA(raw_image.data[raw_index + 0], raw_image.data[raw_index + 1], raw_image.data[raw_index + 2], raw_image.data[raw_index + 3]);
    }
  }

  struct result res;
  res.code    = RES_NONE;
  res.runtime = 0;

  // Measure elapsed time
  struct timeval time_start, time_end;
  gettimeofday(&time_start, NULL);

  // Switch transformation type
  if (strcmp(argv[1], "swap") == 0) {
    res = swap(&raw_image, raw_image.cols, raw_image.rows, image);
  } else if (strcmp(argv[1], "gray") == 0) {
    res = gray(&raw_image, raw_image.cols, raw_image.rows, image);
  } else if (strcmp(argv[1], "blur") == 0) {
    int area = 11;

    if (argc == 5) { area = atoi(argv[4]); }

    res = blur(&raw_image, raw_image.cols, raw_image.rows, image, area);
  } else if (strcmp(argv[1], "emboss") == 0) {
    res = emboss(&raw_image, raw_image.cols, raw_image.rows, image);
  } else {
    term_msg("\nUnsupported Transformation: %s\n", argv[1]);
  }

  // Measure elapsed time
  gettimeofday(&time_end, NULL);
  #ifndef GNUPLOT_MODE
  printf(
    "\nElapsed time: %ld usec (%ld usec)\n",
    (time_end.tv_usec - time_start.tv_usec) + ((time_end.tv_sec - time_start.tv_sec) * 1000000),
    res.runtime
  );
  #else
  printf(
    "%ld %ld",
    (time_end.tv_usec - time_start.tv_usec) + ((time_end.tv_sec - time_start.tv_sec) * 1000000),
    res.runtime
  );
  #endif

  // Save output to disk
  Mat out_image;

  switch (res.code) {
    case RES_NONE:
      term_msg("\nTransformation returned no result!\n");
    case RES_ARRAY:
      out_image = Mat(raw_image.rows, raw_image.cols, CV_8UC4, image);
      break;
    case RES_IMAGE:
      out_image = raw_image;
      break;
    default:
      term_msg("\nTransformation returned unkown result type: %d\n", res.code);
  }

  // Write image to disk with PNG compression
  std::vector<int> compression_params;
  compression_params.push_back(CV_IMWRITE_PNG_COMPRESSION);
  compression_params.push_back(9);

  imwrite(argv[3], out_image, compression_params);

  // Cleanup memory
  free(image);

  return 0;
}
