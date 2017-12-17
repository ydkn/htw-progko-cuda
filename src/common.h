/*
  common.c - Common stuff used in the different implementations
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdlib.h>
#include "config.h"


#pragma mark Color Channel Indices

uint8_t const RED_IDX   = 0;
uint8_t const GREEN_IDX = 1;
uint8_t const BLUE_IDX  = 2;
uint8_t const ALPHA_IDX = 3;


#pragma mark Results

int const RES_NONE  = 0;
int const RES_ARRAY = 1;
int const RES_IMAGE = 2;

struct result {
	int  code;
	long runtime;
};


#pragma mark Preprocessor functions

#define ALPHA(pixel)  ((pixel)>>24)
#define BLUE(pixel)   (((pixel)>>16)&0xFF)
#define GREEN(pixel)  (((pixel)>>8)&0xFF)
#define RED(pixel)    ((pixel)&0xFF)
#define RGBA(r,g,b,a) ((((a) << 24)) | (((b) << 16)) | (((g) << 8)) | ((r)))
