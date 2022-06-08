use v6.d;

unit module CanvasSDL;
use SDL2::Raw;

class Color is export {
    has Int $.r is rw;
    has Int $.g is rw;
    has Int $.b is rw;
}

class Canvas is export {
    has Int $.width = 800;
    has Int $.height = 600;
    has $!window;
    has $!render;

    method Initialize() {
        die "Error initializing SDL" if SDL_Init(VIDEO) != 0;
        $!window = SDL_CreateWindow(
                "Canvas",
                SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
                $.width, $.height, OPENGL);

        $!render = SDL_CreateRenderer($!window, -1, ACCELERATED +| PRESENTVSYNC);

        SDL_SetRenderDrawColor($!render, 0, 0, 0, 0);
        SDL_RenderClear($!render);

        SDL_RenderPresent($!render);

    }
    method Destroy() {
        SDL_Quit();
    }
    method PutPixel(Int $x, Int $y, Color $color) {

        SDL_SetRenderDrawColor($!render, $color.r, $color.g, $color.b, 255);

        my ($screen_x, $screen_y) = $.TransformCoordinates($x, $y);
        SDL_RenderDrawPoint($!render, $screen_x.Int, $screen_y.Int);

    }

    method Draw() {
        SDL_RenderPresent($!render);
    }

    method TransformCoordinates(Int $x, Int $y) {
        ($.width / 2 + $x, $.height / 2 - $y)
    }
}
