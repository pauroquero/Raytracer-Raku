#!/usr/bin/env raku
use v6.d;

unit module Shapes;

use Common;

class Sphere is export {
    has Point3d $.center;
    has Num $.radius;

    has Color $.color;

    has Num $.specular = -1;

    method IntersectRay(Point3d:D $O, Point3d:D $D) {
        my Num $r = $!radius;

        my Point3d $CO = $O - $!center;

        my Num $a = dot($D, $D);
        my Num $b = 2 * dot($CO, $D);
        my Num $c = dot($CO, $CO) - $r * $r;

        my Num $discriminant = $b * $b - 4 * $a * $c;

        if $discriminant < 0 {
            return (Inf, Inf);
        }

        my Num $sq = sqrt($discriminant);
        my Num $t1 = (-$b + $sq) / (2 * $a);
        my Num $t2 = (-$b - $sq) / (2 * $a);
        return ($t1, $t2);
    }
}