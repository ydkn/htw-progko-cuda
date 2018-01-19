/*
  plain.c - Image manipulations without using a framework for parallel computing
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdlib.h>
#include <opencv2/opencv.hpp>
#include "common.h"


#pragma mark Swap Green/Blue

result swap(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  for (uint32_t i = 0; i < height; i++) {
    for (uint32_t j = 0; j < width; j++) {
      uint32_t index = (i * width) + j;

      data[index] = RGBA(RED(data[index]), BLUE(data[index]), GREEN(data[index]), ALPHA(data[index]));
    }
  }

  struct result res;
  res.code    = RES_ARRAY;
  res.runtime = 0;

  return res;
}


#pragma mark Grayscale

result gray(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  for (uint32_t i = 0; i < height; i++) {
    for (uint32_t j = 0; j < width; j++) {
      uint32_t idx = (i * width) + j;

      uint8_t gray = (0.21 * RED(data[idx])) + (0.72 * GREEN(data[idx])) + (0.07 * BLUE(data[idx]));

      data[idx] = RGBA(gray, gray, gray, ALPHA(data[idx]));
    }
  }

  struct result res;
  res.code    = RES_ARRAY;
  res.runtime = 0;

  return res;
}


#pragma mark Blur

result blur(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data, uint8_t area) {
  // Not implemented

  struct result res;
  res.code    = RES_ARRAY;
  res.runtime = 0;

  return res;
}


#pragma mark Emboss

result emboss(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  // Not implemented

  struct result res;
  res.code    = RES_ARRAY;
  res.runtime = -1;

  return res;
}
