use v6.d;

unit module CanvasSDL;
use SDL2::Raw;
use Common;


class Canvas is export {
    has Int $.width = 200;
    has Int $.height = 200;
    has $!window;
    has $!render;
    has $!surface;

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
    method PutPixel(Point2d $coord, Color $color) {

        SDL_SetRenderDrawColor($!render, $color.r, $color.g, $color.b, 255);

        my Point2d $screen_coord = $.TransformCoordinates($coord);
        SDL_RenderDrawPoint($!render, $screen_coord.x, $screen_coord.y);

    }

    method Draw() {
        SDL_RenderPresent($!render);
    }

    method TransformCoordinates(Point2d $coord) returns Point2d {
        Point2d.new(x => ($.width / 2 + $coord.x).Int, y => ($.height / 2 - $coord.y).Int)
    }
}
