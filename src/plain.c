/*
  plain.c - Image manipulations without using a framework for parallel computing
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdlib.h>
#include <opencv2/opencv.hpp>
#include "common.h"


#pragma mark Swap Green/Blue

int swap(cv::Mat image, uint32_t width, uint32_t height, uint8_t data[][4]) {
  uint8_t (*img)[4] = (uint8_t (*)[4]) data;

  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      int index = (i * width) + j;

      uint8_t green = img[index][GREEN_IDX];
      uint8_t blue  = img[index][BLUE_IDX];

      img[index][GREEN_IDX] = blue;
      img[index][BLUE_IDX]  = green;
    }
  }

  return RES_ARRAY;
}


#pragma mark Grayscale

int gray(cv::Mat image, uint32_t width, uint32_t height, uint8_t data[][4]) {
  return RES_ARRAY;
}


#pragma mark Blur

int blur(cv::Mat image, uint32_t width, uint32_t height, uint8_t data[][4], uint8_t area) {
  return RES_ARRAY;
}


#pragma mark Emboss

int emboss(cv::Mat image, uint32_t width, uint32_t height, uint8_t data[][4]) {
  return RES_ARRAY;
}
