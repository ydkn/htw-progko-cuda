#!/bin/bash
#
# generate_scaled_images.sh - Generated scaled images for performance analysis
# Copyright (c) 2017 Elsa Buchholz, Florian Schwab


mkdir -p "./scaled_images/$(basename $1)"

for i in `seq 1 200`; do
  size=$(($i * 10))

  convert $1 -resize "${size}x${size}" "./scaled_images/$(basename $1)/${size}x${size}.png"
done
