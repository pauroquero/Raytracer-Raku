#include <cmath>
#include <algorithm>
#include <iostream>

#include "Common.h"

Color::Color(uint8_t r, uint8_t g, uint8_t b) {
	this->r = r;
	this->g = g;
	this->b = b;
}
Color Color::mul(double intensity) {
	return Color(std::min((int)(r * intensity), 255),
			std::min((int)(g * intensity),255),
			std::min((int)(b * intensity),255));
}

Color Color::operator+ (Color c2) {
	return Color(std::min((int)(r + c2.r), 255),
			std::min((int)(g + c2.g),255),
			std::min((int)(b + c2.b),255));
}


Point2d::Point2d(double x, double y) {
	this->x = x;
	this->y = y;
}

Point3d::Point3d(double x, double y, double z) {
	this->x = x;
	this->y = y;
	this->z = z;
}

double Point3d::length() {
	return std::sqrt(std::pow(x, 2) + std::pow(y, 2) + std::pow(z, 2));
}

Point3d Point3d::operator-() {
	return Point3d(-x, -y, -z);
}

Point3d Point3d::operator-(Point3d c2) {
	return Point3d(x - c2.x, y - c2.y, z - c2.z);
}

Point3d Point3d::operator+(Point3d c2) {
	return Point3d(x + c2.x, y + c2.y, z + c2.z);
}

Point3d operator*(double x, Point3d p) {
	return Point3d(x * p.x, x * p.y, x * p.z);
}
Point3d operator*(Point3d p, double x) {
	return x * p;
}

Point3d operator/(Point3d p, double x) {
	return Point3d(p.x / x, p.y / x, p.z / x);
}

double dot(Point3d lhs, Point3d rhs) {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
}
