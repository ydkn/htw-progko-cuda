/*
  plain.c - Image manipulations without using a framework for parallel computing
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdlib.h>
#include <opencv2/opencv.hpp>
#include "common.h"


#pragma mark Swap Green/Blue

int swap(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      int index = (i * width) + j;

      data[index] = RGBA(RED(data[index]), BLUE(data[index]), GREEN(data[index]), ALPHA(data[index]));
    }
  }

  return RES_ARRAY;
}


#pragma mark Grayscale

int gray(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      int idx = (i * width) + j;

      uint8_t gray = (0.21 * RED(data[idx])) + (0.72 * GREEN(data[idx])) + (0.07 * BLUE(data[idx]));

      data[idx] = RGBA(gray, gray, gray, ALPHA(data[idx]));
    }
  }

  return RES_ARRAY;
}


#pragma mark Blur

int blur(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data, uint8_t area) {
  return RES_ARRAY;
}


#pragma mark Emboss

int emboss(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  return RES_ARRAY;
}
