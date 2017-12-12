/*
  common.c - Common stuff used in the different implementations
  Copyright (c) 2017 Elsa Buchholz, Florian Schwab
*/

#include <stdlib.h>


#pragma mark Color Indices

uint8_t const RED_IDX   = 0;
uint8_t const GREEN_IDX = 1;
uint8_t const BLUE_IDX  = 2;
uint8_t const ALPHA_IDX = 3;


#pragma mark Result Types

int const RES_NONE  = 0;
int const RES_ARRAY = 1;
int const RES_IMAGE = 2;
