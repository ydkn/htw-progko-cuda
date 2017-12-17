#!/bin/bash
#
# analyse.sh - Run performance analysis
# Copyright (c) 2017 Elsa Buchholz, Florian Schwab


MODE=$1
IMAGE=$2

if [ -z $MODE ] || [ -z $IMAGE ]; then
  echo "Usage: $0 <mode> <image>"
  exit 1
fi

mkdir -p "./tmp/$(basename $IMAGE)"
rm -f /tmp/.cuda_tmp_analyse.csv

echo "Timing transformation runtimes..."

for i in `seq 1 100`; do
  size=$(($i * 50))
  file="./tmp/$(basename $IMAGE)/${size}x${size}.png"

  convert $IMAGE -resize "${size}x${size}" "${file}"

  runtime_plain=$(./dist/imgtrans-plain $MODE $file /tmp/out.png)
  runtime_opencv=$(./dist/imgtrans-opencv $MODE $file /tmp/out.png)
  runtime_cuda=$(./dist/imgtrans-cuda $MODE $file /tmp/out.png)

  echo "${size} ${runtime_plain} ${runtime_opencv} ${runtime_cuda}" >> /tmp/.cuda_tmp_analyse.csv
  echo "${size}x${size}: ${runtime_plain} , ${runtime_opencv} , ${runtime_cuda}"
done

echo "Generating graph..."
gnuplot ./analyse.gnu

rm -f /tmp/out.png >/dev/null 2>&1
