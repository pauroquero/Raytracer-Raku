#ifndef _SHAPES_H_
#define _SHAPES_H_
#include "Common.h"
struct Sphere {
	Point3d center;
	double radius;

	Color color;

	double specular;

	double reflective;

	Sphere(Point3d center, double radius, Color color, double specular, double reflective);

	std::pair<double, double> intersectRay(Point3d Origin, Point3d Direction);
};

#endif // _SHAPES_H_
