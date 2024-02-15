#include "Engine.cuh"

Engine::Engine()
{
	UseBufferA = true;
	wm = new WindowManager();

	CellType* InitializationBuffer = new CellType[GridCount];
	err = cudaMalloc(&CellBufferA, sizeof(CellType) * GridCount);
	ERRORCHECK;
	err = cudaMalloc(&CellBufferB, sizeof(CellType) * GridCount);
	ERRORCHECK;
	InitializationBuffer = new CellType[GridCount];
	SetupInitialBuffer(InitializationBuffer);

	err = cudaMemcpy(CellBufferA, InitializationBuffer, sizeof(CellType) * GridCount, cudaMemcpyHostToDevice);
	ERRORCHECK;
	delete[] InitializationBuffer;
	clock.restart();
}

bool Engine::Tick()
{
	SETUPCUDAFUNCTION(ProcessCells, GridCount, !UseBufferA ? CellBufferA : CellBufferB, UseBufferA ? CellBufferA : CellBufferB);
	ERRORCHECKLAST;
	err = cudaDeviceSynchronize();
	ERRORCHECK;
	wm->DrawScene(UseBufferA ? CellBufferA : CellBufferB);
	UseBufferA = !UseBufferA;
	if (!wm->Tick()) return false;
	//printf("%i\n", sf::microseconds(1000000 / ((double)MaxFPS) - clock.getElapsedTime().asMicroseconds()));
	if(1000000 / ((double)MaxFPS) - clock.getElapsedTime().asMicroseconds() > 0)sf::sleep(sf::microseconds(1000000 / ((double)MaxFPS) - clock.getElapsedTime().asMicroseconds()));
	clock.restart();
}

void Engine::SetupInitialBuffer(CellType* bufferStart)
{
	srand(static_cast <unsigned> (time(0)));
	for (int i = 0; i < GridCount; i++) {
		//bufferStart[i] = 1;
		//continue;
		bufferStart[i] = (CellType)(rand() % CellType::MAX);
	}
}

__global__ void ProcessCells(CellType* NewBuffer, CellType* OldBuffer)
{
	GETID(GridCount);

	int x = id % Width;
	int y = id / Width;

	short n[CellType::MAX];
	for (sf::Uint8 i = None; i < CellType::MAX; i++) n[i] = 0;
	

	//get neighbours
	for (int dx = -ViewDistance; dx <= ViewDistance; ++dx) {
		for (int dy = -ViewDistance; dy <= ViewDistance; ++dy) {
			if (IsValidPosition(x + dx, y + dy) && dx != 0 && dy != 0) 
				++n[OldBuffer[IndexFromPosition(x + dx, y + dy)]];
		}
	}

	NewBuffer[id] = GetNewCell(OldBuffer[id], n);
}
