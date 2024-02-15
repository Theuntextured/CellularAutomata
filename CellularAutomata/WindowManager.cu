#include "WindowManager.cuh"

WindowManager::WindowManager()
{
	Window.create(sf::VideoMode(WindowWidth, WindowHeight), sf::String("Cellular Automata"), sf::Style::None);

    err = cudaMalloc(&d_PixelBuffer, sizeof(sf::Uint8) * GridCount * 4);
    ERRORCHECK;
    PixelBuffer = new sf::Uint8[GridCount * 4];

    RenderTexture.create(Width, Height);
    RenderTexture.setSmooth(false);
    RenderSprite.setScale((float)WindowWidth / (float)Width, (float)WindowHeight / (float)Height);
}

bool WindowManager::Tick()
{
    sf::Event event;
    while (Window.pollEvent(event))
    {
        if (event.type == sf::Event::Closed)
            Window.close();
    }

    return Window.isOpen();
}

void WindowManager::DrawScene(CellType* Cells)
{
    SETUPCUDAFUNCTION(RenderCells, GridCount, Cells, d_PixelBuffer);
    ERRORCHECKLAST;
    err = cudaDeviceSynchronize();
    ERRORCHECK;
    err = cudaMemcpy(PixelBuffer, d_PixelBuffer, sizeof(sf::Uint8) * 4 * GridCount, cudaMemcpyDeviceToHost);
    RenderTexture.update(PixelBuffer);
    RenderSprite.setTexture(RenderTexture);
    Window.clear();
    Window.draw(RenderSprite);
    Window.display();
}

__global__ void RenderCells(CellType* Cells, sf::Uint8* pixels)
{
    GETID(GridCount);
    pixels[id * 4 + 0] = GetCellColor(Cells[id], r);
    pixels[id * 4 + 1] = GetCellColor(Cells[id], g);
    pixels[id * 4 + 2] = GetCellColor(Cells[id], b);
    pixels[id * 4 + 3] = GetCellColor(Cells[id], a);
}
