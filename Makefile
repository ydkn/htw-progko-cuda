NVCC=nvcc
INCDIRS=-I./lib

all:
	mkdir -p ./dist
	$(NVCC) src/cudatransform.cu lib/pnglite.c lib/miniz.c $(INCDIRS) -o dist/cudatransform
