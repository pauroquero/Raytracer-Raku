#ifndef _COLOR_H_
#define _COLOR_H_
#include <cstdint>

class Color {
	public:
		uint8_t r;
		uint8_t g;
		uint8_t b;

		Color(uint8_t r, uint8_t g, uint8_t b);

		Color mul(double intensity);

		Color operator+(Color c2);
};

struct Point2d {
	int64_t x;
	int64_t y;

	Point2d(double x, double y);
};

class Point3d {
	public:
		double x;
		double y;
		double z;

		Point3d(double x, double y, double z);
		double length();

		Point3d operator-();
		Point3d operator-(Point3d c2);
		Point3d operator+(Point3d c2);
};

Point3d operator*(double x, Point3d p);
Point3d operator*(Point3d p, double x);
Point3d operator/(Point3d p, double x);

double dot(Point3d lhs, Point3d rhs);

#endif // _COLOR_H_
