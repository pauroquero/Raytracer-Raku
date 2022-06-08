#!/usr/bin/env raku
use v6.d;

unit module SceneElems;

use Common;
use CanvasSDL;
use Shapes;


class Viewport is export {
    has Num $.width = 1.0.Num;
    has Num $.height = 1.0.Num;
    has Num $.distance = 1.0.Num;

    method CanvasToViewport(Point2d $canvas_coord, Int $canvas_width, Int $canvas_height) {
        Point3d.new(
                x => $canvas_coord.x * $.width / $canvas_width.Num,
                y => $canvas_coord.y * $.height / $canvas_height.Num,
                z => $.distance,
                )
    }
}


class Scene is export {
    has $.spheres;
}


class Camera is export {
    has Viewport $.viewport;
    has Canvas $.canvas;

    has Point3d $.position;

    method Render (Scene $scene) {
        my Int $min_x = -$.canvas.width div 2;
        my Int $max_x = $.canvas.width div 2;
        my Int $min_y = -$.canvas.height div 2;
        my Int $max_y = $.canvas.height div 2;
        for $min_x .. $max_x -> Int $x {
            for $min_y .. $max_y -> Int $y {
                my $canvas_coord = Point2d.new(x => $x, y => $y);

                my $D = $.viewport.CanvasToViewport($canvas_coord, $.canvas.width, $.canvas.height);
                my $color = $.TraceRay($.position, $D, $.viewport.distance, Inf, $scene);
                $.canvas.PutPixel($canvas_coord, $color);
            }
            if $x mod 10 == 0 {
                say "Rendering line $x";
                $.canvas.Draw();
            }
        }
    }

    method TraceRay(Point3d $origin, Point3d $D, Num $t_min, Num $t_max, Scene $scene) returns Color {
        my Num $closest_t = Inf;
        my Sphere $closest_sphere = Nil;

        for $scene.spheres -> Sphere $sphere {
            my (Num $t1, Num $t2) = $sphere.IntersectRay($origin, $D);
            if $t_min < $t1 < $t_max && $t1 < $closest_t {
                $closest_t = $t1;
                $closest_sphere = $sphere;
            }
            if $t_min < $t2 < $t_max && $t2 < $closest_t {
                $closest_t = $t2;
                $closest_sphere = $sphere;
            }
        }
        if !defined($closest_sphere) {
            BACKGROUND_COLOR;
        } else {
            $closest_sphere.color;
        }
    }

}
