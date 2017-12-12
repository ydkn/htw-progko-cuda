/*
  cudatransform.cu - Image manipulations using CUDA
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
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

extern int swap(cv::Mat image, uint32_t width, uint32_t height, uint8_t data[][4]);
extern int gray(cv::Mat image, uint32_t width, uint32_t height, uint8_t data[][4]);
extern int blur(cv::Mat image, uint32_t width, uint32_t height, uint8_t data[][4], uint8_t area);
extern int emboss(cv::Mat image, uint32_t width, uint32_t height, uint8_t data[][4]);


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
    printf("Using image: %s\n", argv[2]);
  }

  // convert image/matrix to a plain 2-dim array to allow passing same input to all functions
  uint8_t image[raw_image.rows * raw_image.cols][4];

  for (int i = 0; i < raw_image.rows; i++) {
    for (int j = 0; j < raw_image.cols; j++) {
      int raw_index = (i * raw_image.cols + j) * 4;
      int index     = (i * raw_image.cols) + j;

      image[index][RED_IDX]   = raw_image.data[raw_index + 0];
      image[index][GREEN_IDX] = raw_image.data[raw_index + 1];
      image[index][BLUE_IDX]  = raw_image.data[raw_index + 2];
      image[index][ALPHA_IDX] = raw_image.data[raw_index + 3];
    }
  }

  int result = RES_NONE;

  // Switch transformation type
  if (strcmp(argv[1], "swap") == 0) {
    result = swap(raw_image, raw_image.cols, raw_image.rows, image);
  } else if (strcmp(argv[1], "gray") == 0) {
    result = gray(raw_image, raw_image.cols, raw_image.rows, image);
  } else if (strcmp(argv[1], "blur") == 0) {
    int area = 11;

    if (argc == 5) { area = atoi(argv[4]); }

    result = blur(raw_image, raw_image.cols, raw_image.rows, image, area);
  } else if (strcmp(argv[1], "emboss") == 0) {
    result = emboss(raw_image, raw_image.cols, raw_image.rows, image);
  } else {
    term_msg("\nUnsupported Transformation: %s\n", argv[1]);
  }

  Mat out_image;

  switch (result) {
    case RES_ARRAY:
      out_image = Mat(raw_image.rows, raw_image.cols, CV_8UC4, &image);
      break;
    case RES_IMAGE:
      out_image = raw_image;
      break;
    default:
      term_msg("\nTransformation returned unkown result type: %d\n", result);
  }

  imwrite(argv[3], out_image);

  return 0;
}
