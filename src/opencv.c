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

int swap(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  Mat channels[4];

  split(*image, channels);

  Mat green = channels[GREEN_IDX];
  Mat blue  = channels[BLUE_IDX];

  channels[GREEN_IDX] = blue;
  channels[BLUE_IDX] = green;

  merge(channels, 4, *image);

  return RES_IMAGE;
}


#pragma mark Grayscale

int gray(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  cvtColor(*image, *image, CV_BGR2GRAY);

  return RES_IMAGE;
}


#pragma mark Blur

int blur(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data, uint8_t area) {
  return RES_NONE;
}


#pragma mark Emboss

int emboss(cv::Mat *image, uint32_t width, uint32_t height, uint32_t *data) {
  return RES_NONE;
}
