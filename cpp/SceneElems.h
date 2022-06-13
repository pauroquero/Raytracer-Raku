#ifndef _SCENEELEMS_H_
#include <vector>
#include <cstdint>
#include <iostream>

#include "Common.h"
#include "Shapes.h"
#include "CanvasSDL.h"

struct Scene;

struct Viewport {
	double width;
	double height;
	double distance;

	Viewport(): width(1), height(1), distance(1) {}

	Point3d CanvasToViewport(Point2d canvas_coord,
			int64_t canvas_width, int64_t canvas_height);
};

struct Camera {
    Viewport &viewport;
    Canvas &canvas;

    Point3d position;

    Camera(Viewport &viewport, Canvas &canvas, Point3d position):
	    viewport(viewport), canvas(canvas), position(position) {};
    void Render (Scene &scene);
};

struct Light {
	double intensity;
	Light(double intensity): intensity(intensity) {};
};

struct AmbientLight: Light {

	AmbientLight(double intensity): Light(intensity) {};
};

struct PointLight: Light {
	Point3d position;

	PointLight(double intensity, Point3d position): 
		Light(intensity), position(position) {};
};

struct DirectionalLight: Light {
	Point3d direction;

	DirectionalLight(double intensity, Point3d direction): 
		Light(intensity), direction(direction) {};
};

struct Lights {
	std::vector<AmbientLight> ambient_lights;
	std::vector<PointLight> point_lights;
	std::vector<DirectionalLight> directional_lights;

	Lights(std::vector<AmbientLight> ambient_lights,
			std::vector<PointLight> point_lights,
			std::vector<DirectionalLight> directional_lights):
		ambient_lights(ambient_lights), point_lights(point_lights), directional_lights(directional_lights) {};

	double ComputeLighting(Point3d point, Point3d normal, Point3d view_angle,
			double specular, Scene &scene);

	double Directionintensity(Light &light, Point3d point,
			Point3d light_direction, Point3d normal,
			Point3d view_angle, double specular,
			Scene &scene, double t_max);
};

struct Scene {
	std::vector<Sphere> spheres;
	Lights &lights;
	std::pair<Sphere *, double> Closestintersection(Point3d origin, Point3d direction,
		double t_min, double t_max);

	Scene(std::vector<Sphere> spheres, Lights &lights): spheres(spheres), lights(lights) {};
};

#define _SCENEELEMS_H_
#endif // _SCENEELEMS_H_
