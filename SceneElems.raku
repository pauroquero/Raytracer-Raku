#!/usr/bin/env raku
use v6.d;

unit module SceneElems;

use Common;
use CanvasSDL;
use Shapes;

sub ReflectRay(Point3d $incoming, Point3d $normal) returns Point3d {
    mul(2 * dot($normal, $incoming), $normal) - $incoming;
}

class Scene is export {...}

class Viewport is export {
    has num64 $.width = 1.0.Num;
    has num64 $.height = 1.0.Num;
    has num64 $.distance = 1.0.Num;

    method CanvasToViewport(Point2d:D $canvas_coord,
                            int64:D $canvas_width, Int:D $canvas_height) returns Point3d:D {
        Point3d.new(
                x => $canvas_coord.x * $!width / $canvas_width.Num,
                y => $canvas_coord.y * $!height / $canvas_height.Num,
                z => $!distance,
                )
    }
}

role Light {}

class AmbientLight does Light is export {
    has num64 $.intensity;
}

class PointLight does Light is export {
    has num64 $.intensity;
    has Point3d $.position;
}

class DirectionalLight does Light is export {
    has num64 $.intensity;
    has Point3d $.direction;
}

class Lights is export {
    has @.ambient_lights of AmbientLight;
    has @.point_lights of PointLight;
    has @.directional_lights of DirectionalLight;

    method ComputeLighting(Point3d:D $point, Point3d:D $normal, Point3d:D $view_angle,
                           num64:D $specular, Scene:D $scene) returns num64 {
        my num64 $intensity = 0.Num;

        for @!ambient_lights -> $light {
            $intensity += $light.intensity;
        }

        for @!point_lights -> $light {
            my Point3d $light_direction = $light.position - $point;
            $intensity += $.Directionintensity($light, $point, $light_direction,
                    $normal, $view_angle, $specular, $scene, 1.0e0);
        }

        for @!directional_lights -> $light {
            $intensity += $.Directionintensity($light, $point, $light.direction,
                    $normal, $view_angle, $specular, $scene, Inf);
        }
        $intensity;
    }
    method Directionintensity(Light:D $light, Point3d:D $point,
                              Point3d:D $light_direction, Point3d:D $normal,
                              Point3d:D $view_angle, num64:D $specular,
                              $scene, num64:D $t_max) returns num64 {
        my num64 $intensity = 0.Num;

        # Shadow check
        my (Sphere:D $shadow_sphere, num64:D $closest_t) =
                $scene.Closestintersection($point, $light_direction, 0.001e0, $t_max);
        if defined $shadow_sphere {
            return 0.Num;
        }

        # Diffuse
        my num64 $dot_vectors = dot($light_direction, $normal);
        if $dot_vectors > 0 {
            $intensity += $light.intensity * $dot_vectors / ($light_direction.length * $normal.length);
        }

        # Specular
        if $specular != -1 {
            my Point3d $reflected_direction = ReflectRay($light_direction, $normal);
            my num64 $r_dot_v = dot($reflected_direction, $view_angle);
            if $r_dot_v > 0 {
                try {
                    $intensity += $light.intensity * ($r_dot_v / ($reflected_direction.length * $view_angle
                    .length)) ** $specular;
                }
            }
        }
        $intensity;
    }
}


class Scene is export {
    has @.spheres of Sphere;
    has Lights $.lights;

    method Closestintersection(Point3d:D $origin, Point3d:D $direction,
                               num:D $t_min, num:D $t_max) {
        my num64 $closest_t = Inf;
        my Sphere $closest_sphere = Nil;

        for @!spheres -> Sphere $sphere {
            my (num64 $t1, num64 $t2) = $sphere.intersectRay($origin, $direction);
            if $t_min < $t1 < $t_max && $t1 < $closest_t {
                $closest_t = $t1;
                $closest_sphere = $sphere;
            }
            if $t_min < $t2 < $t_max && $t2 < $closest_t {
                $closest_t = $t2;
                $closest_sphere = $sphere;
            }
        }

        ($closest_sphere, $closest_t);
    }
}


class Camera is export {
    has Viewport $.viewport;
    has Canvas $.canvas;

    has Point3d $.position;

    method Render (Scene:D $scene) {
        my int64 $min_x = -$!canvas.width div 2;
        my int64 $max_x = $!canvas.width div 2;
        my int64 $min_y = -$!canvas.height div 2;
        my int64 $max_y = $!canvas.height div 2;
        for $min_x .. ($max_x - 1) -> int64 $x {
            for $min_y .. ($max_y - 1) -> int64 $y {
                my $canvas_coord = Point2d.new(x => $x, y => $y);

                my $D = $!viewport.CanvasToViewport($canvas_coord, $!canvas.width, $!canvas.height);
                my $color = TraceRay($!position, $D, $!viewport.distance, Inf, $scene, 3.Int);
                $!canvas.PutPixel($canvas_coord, $color);
            }
            if $x mod 10 == 0 {
                say "Rendering line $x";
            }
            $!canvas.Draw();
        }
    }
}

sub TraceRay(Point3d:D $origin, Point3d:D $direction,
                num64:D $t_min, num64:D $t_max, Scene:D $scene,
                int64 $recursion_depth) returns Color {
    my (Sphere:D $closest_sphere, num64:D $closest_t) =
            $scene.Closestintersection($origin, $direction, $t_min, $t_max);

    if !defined($closest_sphere) {
        return BACKGROUND_COLOR;
    }

    # Compute local color
    my Point3d $collision_point = $origin + mul($closest_t, $direction);
    my Point3d $normal = $collision_point - $closest_sphere.center;
    $normal = div($normal, $normal.length);
    my Color $local_color = $closest_sphere.color.mul($scene.lights.ComputeLighting(
            $collision_point, $normal,
            -$direction, $closest_sphere.specular, $scene));

    # If this sphere is not reflective or we reach the recursion limit, return
    my num64 $reflective = $closest_sphere.reflective;
    if $recursion_depth < 0 || $reflective <= 0 {
        return $local_color;
    }

    # Compute reflected color
    my Point3d $reflected_ray = ReflectRay(-$direction, $normal);

    my Color $reflected_color = TraceRay($collision_point, $reflected_ray,
            0.001.Num, Inf.Num, $scene,
            $recursion_depth - 1);

    return $local_color.mul(1 - $reflective)
            + $reflected_color.mul($reflective);
}
