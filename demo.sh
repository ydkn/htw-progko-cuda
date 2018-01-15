#!/bin/bash

set -e

CUDA_SERVER=""
CUDA_SERVER_USER=""
REMOTE_PATH="~/cuda_demo"

MODE=$1
SRC_IMAGE=$2

rm -f /tmp/cuda_demo.png
ssh $CUDA_SERVER_USER@$CUDA_SERVER "rm -rf $REMOTE_PATH"
ssh $CUDA_SERVER_USER@$CUDA_SERVER "mkdir -p $REMOTE_PATH/out"
scp -r Makefile src examples $CUDA_SERVER_USER@$CUDA_SERVER:$REMOTE_PATH
ssh $CUDA_SERVER_USER@$CUDA_SERVER "bash -lc 'cd $REMOTE_PATH && make cuda'"
ssh $CUDA_SERVER_USER@$CUDA_SERVER "cd $REMOTE_PATH && dist/imgtrans-cuda $MODE $SRC_IMAGE $REMOTE_PATH/out/demo.png"
scp $CUDA_SERVER_USER@$CUDA_SERVER:$REMOTE_PATH/out/demo.png /tmp/cuda_demo.png
open $SRC_IMAGE
open /tmp/cuda_demo.png
