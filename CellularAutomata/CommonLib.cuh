#pragma once

#include <SFML/Graphics.hpp>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "Settings.cuh"
#include <SFML/System.hpp>

#define GETID(a) int id = blockIdx.x * blockDim.x + threadIdx.x; \
		if(id >= a) return
#define GridCount Width * Height
#define ERRORCHECKLAST	err = cudaGetLastError();\
					if ( err != cudaSuccess ) {\
						printf("CUDA Error: %s\n", cudaGetErrorString(err));\
						throw;\
					}
#define ERRORCHECK 	if ( err != cudaSuccess ) {\
						printf("CUDA Error: %s\n", cudaGetErrorString(err));\
						throw;\
					}
#define RAND(LO, HI) (LO + static_cast <float> (rand()) / (static_cast <float> (RAND_MAX / (HI - LO))))
#define MIN(A, B) (A > B ? B : A)
#define MAX(A, B) (A > B ? A : B)
#define CLAMP(VALUE, LO, HI) VALUE = MIN(MAX(LO, VALUE), HI)
#define SETUPCUDAFUNCTION(FUNCTION, A, ...) FUNCTION<<<(A + 1023) / 1024, 1024>>>(__VA_ARGS__)

inline sf::Vector2i PositionFromIndex(int i) {
	return sf::Vector2i(i % Width, i / Width);
}
__device__ __host__ inline int IndexFromPosition(int x, int y) {
	return y * Width + x;
}
inline int IndexFromPosition(sf::Vector2i p) {
	return IndexFromPosition(p.x, p.y);
}

__device__ __host__ inline bool IsValidPosition(int x, int y) {
	return x >= 0 && y >= 0 && x < Width && y < Height;
}