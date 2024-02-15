#pragma once

#include "CommonLib.cuh"
#include "Cell.cuh"


class WindowManager
{
public:
	WindowManager();
	bool Tick();
	void DrawScene(CellType* Cells);
private:
	sf::RenderWindow Window;
	sf::Texture RenderTexture;
	sf::Sprite RenderSprite;
	sf::Uint8* d_PixelBuffer;
	sf::Uint8* PixelBuffer;
	cudaError_t err;
};

__global__ void RenderCells(CellType* Cells, sf::Uint8* pixels);