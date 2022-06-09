use v6.d;

unit module Common;

class Color is export {
    has Int $.r is rw;
    has Int $.g is rw;
    has Int $.b is rw;

    method mul(Num:D $intensity) returns Color:D {
        Color.new(
                r => min(($!r * $intensity), 255).Int,
                g => min(($!g * $intensity),255).Int,
                b => min(($!b * $intensity),255).Int,
                );
    }
}

constant BACKGROUND_COLOR is export = Color.new(r => 0, g => 0, b => 0);

class Point2d is export {
    has Int $.x is rw;
    has Int $.y is rw;
}

class Point3d is export {
    has Num $.x is rw;
    has Num $.y is rw;
    has Num $.z is rw;

    method length returns Num:D {
        sqrt($!x**2 + $!y**2 + $!z**2);
    }
}

multi prefix:<->(Point3d:D $x) returns Point3d:D is export {
    Point3d.new(
            x => -$x.x,
            y => -$x.y,
            z => -$x.z,
            );
}
multi infix:<->(Point3d:D $lhs, Point3d:D $rhs) returns Point3d:D is export {
    Point3d.new(
            x => $lhs.x - $rhs.x,
            y => $lhs.y - $rhs.y,
            z => $lhs.z - $rhs.z,
            )
}

multi infix:<+>(Point3d:D $lhs, Point3d:D $rhs) returns Point3d:D is export {
    Point3d.new(
            x => $lhs.x + $rhs.x,
            y => $lhs.y + $rhs.y,
            z => $lhs.z + $rhs.z,
            )
}

sub mul (Num:D $lhs, Point3d:D $rhs) returns Point3d:D is export {
    Point3d.new(
            x => $lhs * $rhs.x,
            y => $lhs * $rhs.y,
            z => $lhs * $rhs.z,
            )
}

sub div (Point3d:D $rhs, Num:D $lhs) returns Point3d:D is export {
    Point3d.new(
            x => $rhs.x / $lhs,
            y => $rhs.y / $lhs,
            z => $rhs.z / $lhs,
            )
}

sub dot(Point3d:D $lhs, Point3d:D $rhs) returns Num:D is export {
    $lhs.x * $rhs.x + $lhs.y * $rhs.y + $lhs.z * $rhs.z;
}