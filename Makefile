GCC=g++
NVCC=nvcc
LD=-lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgproc


pre-build:
	mkdir -p ./dist

plain: pre-build
	$(GCC) -x c++ src/plain.c src/imgtrans.c $(LD) -o dist/imgtrans-plain

opencv: pre-build
	$(GCC) -x c++ src/opencv.c src/imgtrans.c $(LD) -o dist/imgtrans-opencv

cuda: pre-build
	$(NVCC) -x cu src/cuda.cu src/imgtrans.c $(LD) -o dist/imgtrans-cuda

clean: pre-build
	rm -rf ./dist/*

all: plain opencv cuda
