use v6.d;

unit module CanvasSDL;
use NativeCall;
use SDL2::Raw;
use Common;

my &memset = $*KERNEL ~~ /win32/
        ?? sub (Pointer $str, int32 $c, size_t $n) returns Pointer is symbol('memset') is native('ucrtbase') {*}
        !! sub (Pointer $str, int32 $c, size_t $n) returns Pointer is symbol('memset') is native {*};

class Canvas is export {
    has Int $.width = 200;
    has Int $.height = 200;
    has $!window;
    has $!render;
    has $!screen;

    method Initialize() {
        die "Error initializing SDL" if SDL_Init(VIDEO) != 0;
        $!window = SDL_CreateWindow(
                "Canvas",
                SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
                $!width, $!height, SHOWN);

        $!screen = SDL_GetWindowSurface($!window);

        SDL_LockSurface($!screen);

        memset($!screen.pixels, 0xffffffff, $!height * $!width * 4);

    }
    method Destroy() {
        SDL_DestroyWindow($!window);
        SDL_Quit();
    }
    method PutPixel(Point2d:D $coord, Color:D $color) {

        my Point2d $screen_coord = $.TransformCoordinates($coord);

        my CArray[uint32] $pixels = nativecast(CArray[uint32], $!screen.pixels);
        my uint32 $color_bin = SDL_MapRGBA($!screen.format, $color.r, $color.g, $color.b, 0xff);
        my UInt $offset = $screen_coord.x + $screen_coord.y * $!width;
        if $offset > 0 && $offset < $!height * $!width - 10 {
            $pixels[$offset] = $color_bin;
        }
    }

    method Draw() {
        SDL_UnlockSurface($!screen);

        my $event = SDL_Event.new;
        while SDL_PollEvent($event) {
            my $casted_event = SDL_CastEvent($event);

            given $casted_event {
                when *.type == QUIT {
                    exit(1);
                }
            }
        }

        SDL_UpdateWindowSurface($!window);
        SDL_LockSurface($!screen);
    }

    method TransformCoordinates(Point2d:D $coord) returns Point2d:D {
        Point2d.new(x => ($!width / 2 + $coord.x).floor.Int, y => ($!height / 2 - $coord.y).floor.Int)
    }
}
