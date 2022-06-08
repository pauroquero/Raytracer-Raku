use v6.d;

unit module Common;

class Color is export {
    has Int $.r is rw;
    has Int $.g is rw;
    has Int $.b is rw;
}

constant BACKGROUND_COLOR is export = Color.new(r => 255, g => 255, b => 255);

class Point2d is export {
    has Int $.x is rw;
    has Int $.y is rw;
}

class Point3d is export {
    has Num $.x is rw;
    has Num $.y is rw;
    has Num $.z is rw;
}

multi infix:<->(Point3d:D $lhs, Point3d:D $rhs) returns Point3d is export {
    Point3d.new(
            x => $lhs.x - $rhs.x,
            y => $lhs.y - $rhs.y,
            z => $lhs.z - $rhs.z,
            )
}

sub dot(Point3d $lhs, Point3d $rhs) returns Num is export {
    $lhs.x * $rhs.x + $lhs.y * $rhs.y + $lhs.z * $rhs.z;
}