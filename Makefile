GCC=g++
NVCC=nvcc
INCDIRS=-I./lib
LD=-lopencv_core -lopencv_imgproc -lopencv_highgui


pre-build:
	mkdir -p ./dist

plain: pre-build
	$(GCC) -x c++ src/imgtrans.c src/plain.c $(INCDIRS) $(LD) -o dist/imgtrans-plain

opencv: pre-build
	$(GCC) -x c++ src/imgtrans.c src/opencv.c $(INCDIRS) $(LD) -o dist/imgtrans-opencv

cuda: pre-build
	$(NVCC) src/imgtrans.c src/cuda.cu $(INCDIRS) $(LD) -o dist/imgtrans-cuda

all: plain opencv cuda
