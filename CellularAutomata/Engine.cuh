#pragma once

#include "CommonLib.cuh"
#include "WindowManager.cuh"
#include "Cell.cuh"

class Engine {
public:
	Engine();
	bool Tick();
private:
	void SetupInitialBuffer(CellType* bufferStart);

	WindowManager* wm;
	bool UseBufferA;
	CellType* CellBufferA;
	CellType* CellBufferB;
	cudaError_t err;
	sf::Clock clock;
};

__global__ void ProcessCells(CellType* NewBuffer, CellType* OldBuffer);

