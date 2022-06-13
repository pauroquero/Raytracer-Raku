use v6.d;

unit module Common;

class Color is export {
    has int64 $.r is rw;
    has int64 $.g is rw;
    has int64 $.b is rw;

    method mul(num64:D $intensity) returns Color:D {
        Color.new(
                r => min(($!r * $intensity), 255).Int,
                g => min(($!g * $intensity),255).Int,
                b => min(($!b * $intensity),255).Int,
                );
    }
}

multi infix:<+>(Color:D $lhs, Color:D $rhs) returns Color:D is export {
    Color.new(
            r => min($lhs.r + $rhs.r, 255),
            g => min($lhs.g + $rhs.g, 255),
            b => min($lhs.b + $rhs.b, 255),
            )
}

constant BACKGROUND_COLOR is export = Color.new(r => 0, g => 0, b => 0);

class Point2d is export {
    has int64 $.x is rw;
    has int64 $.y is rw;
}

class Point3d is export {
    has num64 $.x is rw;
    has num64 $.y is rw;
    has num64 $.z is rw;

    method length returns num64 {
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

sub mul (num64:D $lhs, Point3d:D $rhs) returns Point3d:D is export {
    Point3d.new(
            x => $lhs * $rhs.x,
            y => $lhs * $rhs.y,
            z => $lhs * $rhs.z,
            )
}

sub div (Point3d:D $rhs, num64:D $lhs) returns Point3d:D is export {
    Point3d.new(
            x => $rhs.x / $lhs,
            y => $rhs.y / $lhs,
            z => $rhs.z / $lhs,
            )
}

sub dot(Point3d:D $lhs, Point3d:D $rhs) returns num64 is export {
    $lhs.x * $rhs.x + $lhs.y * $rhs.y + $lhs.z * $rhs.z;
}