extern "C" {
#include <SDL2/SDL.h>
}
#include <cstring>
#include <cmath>
#include <iostream>

#include "Common.h"
#include "CanvasSDL.h"


Canvas::Canvas(int64_t width, int64_t height) : width(width), height(height) {
	if (SDL_Init(SDL_INIT_VIDEO) != 0) {
		std::cerr << "Error initializing sdl\n";
		throw "";
	}
	window = SDL_CreateWindow("Canvas",
			SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
			width, height, SDL_WINDOW_SHOWN);

	screen = SDL_GetWindowSurface(window);

	SDL_LockSurface(screen);

	memset(screen->pixels, 0xffffffff, height * width * 4);

}

Canvas::~Canvas() {
	SDL_DestroyWindow(window);
	SDL_Quit();
}

void Canvas::PutPixel(Point2d coord, Color color) {

	Point2d screen_coord = TransformCoordinates(coord);

	uint32_t *pixels = static_cast<uint32_t *>(screen->pixels);
	uint32_t color_bin = SDL_MapRGBA(screen->format, color.r, color.g, color.b, 0xff);
	int64_t offset = screen_coord.x + screen_coord.y * width;
	if (offset > 0 && offset < height * width) {
		pixels[offset] = color_bin;
	}
}

void Canvas::Draw() {
        SDL_UnlockSurface(screen);

        SDL_Event event;
        while (SDL_PollEvent(&event)) {
		if (event.type == SDL_QUIT) {
			exit(1);
		}
        }

        SDL_UpdateWindowSurface(window);
        SDL_LockSurface(screen);
}

Point2d Canvas::TransformCoordinates(Point2d coord) {
	return Point2d(std::floor((width / 2 + coord.x)), std::floor(height / 2 - coord.y));
}
