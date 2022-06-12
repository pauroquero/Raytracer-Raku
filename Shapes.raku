#!/usr/bin/env raku
use v6.d;

unit module Shapes;

use Common;

class Sphere is export {
    has Point3d $.center;
    has num64 $.radius;

    has Color $.color;

    has num64 $.specular = -1;

    has num64 $.reflective = 0.Num;

    method int64ersectRay(Point3d:D $O, Point3d:D $D) {
        my num64 $r = $!radius;

        my Point3d $CO = $O - $!center;

        my num64 $a = dot($D, $D);
        my num64 $b = 2 * dot($CO, $D);
        my num64 $c = dot($CO, $CO) - $r * $r;

        my num64 $discriminant = $b * $b - 4 * $a * $c;

        if $discriminant < 0 {
            return (Inf, Inf);
        }

        my num64 $sq = sqrt($discriminant);
        my num64 $t1 = (-$b + $sq) / (2 * $a);
        my num64 $t2 = (-$b - $sq) / (2 * $a);
        return ($t1, $t2);
    }
}