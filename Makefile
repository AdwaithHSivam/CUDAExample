
all: 
	nvcc -c square.cu
	nvcc -o square square.o
	./square

clean:
	rm -f square square.o