/*
  opencv.c - Image manipulations using OpenCV
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdlib.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core_c.h>
#include "common.h"

using namespace cv;


#pragma mark Swap Green/Blue

result swap(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  Mat channels[4];

  split(*image, channels);

  Mat green = channels[GREEN_IDX];
  Mat blue  = channels[BLUE_IDX];

  channels[GREEN_IDX] = blue;
  channels[BLUE_IDX] = green;

  merge(channels, 4, *image);

  struct result res;
  res.code    = RES_IMAGE;
  res.runtime = 0;

  return res;
}


#pragma mark Grayscale

result gray(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  // This does not work with alpha channel images
  // Only use RGBA images
  transform(*image, *image, Matx13f(0.07, 0.72, 0.21));

  struct result res;
  res.code    = RES_IMAGE;
  res.runtime = 0;

  return res;
}


#pragma mark Blur

result blur(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data, uint8_t area) {
  // Not implemented

  struct result res;
  res.code    = RES_IMAGE;
  res.runtime = 0;

  return res;
}


#pragma mark Emboss

result emboss(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  // Not implemented

  struct result res;
  res.code    = RES_IMAGE;
  res.runtime = 0;

  return res;
}
