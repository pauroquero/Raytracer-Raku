#include <utility>
#include <cmath>
#include <limits>

#include "Shapes.h"

Sphere::Sphere(Point3d center, double radius, Color color, double specular = -1, double reflective = 0) :
	center(center), radius(radius), color(color), specular(specular), reflective(reflective) {};

std::pair<double, double> Sphere::intersectRay(Point3d Origin, Point3d Direction) {

	Point3d CO = Origin - center;

	double a = dot(Direction, Direction);
	double b = 2 * dot(CO, Direction);
	double c = dot(CO, CO) - radius * radius;

	double discriminant = b * b - 4 * a * c;

	if (discriminant < 0) {
		return std::make_pair(std::numeric_limits<double>::infinity(), std::numeric_limits<double>::infinity());
	}

	double sq = std::sqrt(discriminant);
	double t1 = (-b + sq) / (2 * a);
	double t2 = (-b - sq) / (2 * a);
	return std::make_pair(t1, t2);
}
