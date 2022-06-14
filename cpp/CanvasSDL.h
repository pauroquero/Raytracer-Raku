#ifndef _CANVAS_H_
#define _CANVAS_H_
extern "C" {
#include <SDL2/SDL.h>
}

#include "Common.h"

class Canvas {
	public:
		int64_t width;
		int64_t height;
		SDL_Window *window;
		SDL_Surface *screen;

		Canvas(int64_t width, int64_t height);
		~Canvas();
		void PutPixel(Point2d coord, Color color);
		void Draw();

		Point2d TransformCoordinates(Point2d coord);
};

#endif // _CANVAS_H_
