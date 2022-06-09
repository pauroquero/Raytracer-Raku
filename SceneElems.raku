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

    method CanvasToViewport(Point2d:D $canvas_coord,
                            Int:D $canvas_width, Int:D $canvas_height) returns Point3d:D {
        Point3d.new(
                x => $canvas_coord.x * $!width / $canvas_width.Num,
                y => $canvas_coord.y * $!height / $canvas_height.Num,
                z => $!distance,
                )
    }
}

role Light {}

class AmbientLight does Light is export {
    has Num $.intensity;
}

class PointLight does Light is export {
    has Num $.intensity;
    has Point3d $.position;
}

class DirectionalLight does Light is export {
    has Num $.intensity;
    has Point3d $.direction;
}

class Lights is export {
    has @.ambient_lights of AmbientLight;
    has @.point_lights of PointLight;
    has @.directional_lights of DirectionalLight;

    method ComputeLighting(Point3d:D $point, Point3d:D $normal) returns Num:D {
        my Num $intensity = 0.0.Num;

        for @!ambient_lights -> $light {
            $intensity += $light.intensity;
        }

        for @!point_lights -> $light {
            my Point3d $light_direction = $light.position - $point;
            $intensity += $.DirectionIntensity($light, $light_direction, $normal);
        }

        for @!directional_lights -> $light {
            $intensity += $.DirectionIntensity($light, $light.direction, $normal);
        }
        $intensity;
    }
    method DirectionIntensity(Light:D $light,
                              Point3d:D $light_direction, Point3d:D $normal) returns Num:D {
        my Num $dot_vectors = dot($light_direction, $normal);
        if $dot_vectors > 0 {
            $light.intensity * $dot_vectors / ($light_direction.length * $normal.length);
        } else {
            0.Num;
        }
    }
}


class Scene is export {
    has @.spheres of Sphere;
    has Lights $.lights;
}


class Camera is export {
    has Viewport $.viewport;
    has Canvas $.canvas;

    has Point3d $.position;

    method Render (Scene:D $scene) {
        my Int $min_x = -$!canvas.width div 2;
        my Int $max_x = $!canvas.width div 2;
        my Int $min_y = -$!canvas.height div 2;
        my Int $max_y = $!canvas.height div 2;
        for $min_x .. ($max_x - 1) -> Int $x {
            for $min_y .. ($max_y - 1) -> Int $y {
                my $canvas_coord = Point2d.new(x => $x, y => $y);

                my $D = $!viewport.CanvasToViewport($canvas_coord, $!canvas.width, $!canvas.height);
                my $color = $.TraceRay($!position, $D, $!viewport.distance, Inf, $scene);
                $!canvas.PutPixel($canvas_coord, $color);
            }
            if $x mod 10 == 0 {
                say "Rendering line $x";
                $!canvas.Draw();
            }
        }
    }

    method TraceRay(Point3d:D $origin, Point3d:D $D, Num:D $t_min, Num:D $t_max, Scene:D $scene) returns Color {
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
            my Point3d $collision_point = $origin + mul($closest_t, $D);
            my Point3d $normal = $collision_point - $closest_sphere.center;
            $normal = div($normal, $normal.length);
            $closest_sphere.color.mul($scene.lights.ComputeLighting($collision_point, $normal));
        }
    }

}
