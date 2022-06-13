#include <limits>
#include <utility>
#include <vector>
#include <cstdio>

#include "SceneElems.h"
#include "Common.h"
#include "CanvasSDL.h"
#include "Shapes.h"

Point3d ReflectRay(Point3d incoming, Point3d normal) {
	return 2 * dot(normal, incoming) * normal - incoming;
}

Color TraceRay(Point3d origin, Point3d direction,
		double t_min, double t_max, Scene &scene,
		int recursion_depth);


Point3d Viewport::CanvasToViewport(Point2d canvas_coord,
		int64_t canvas_width, int64_t canvas_height) {
	return Point3d(canvas_coord.x * width / canvas_width,
			canvas_coord.y * height / canvas_height,
			distance);
}



double Lights::ComputeLighting(Point3d point, Point3d normal, Point3d view_angle,
		double specular, Scene &scene) {
	double intensity = 0;

	for (auto &light: ambient_lights) {
		intensity += light.intensity;
	}

	for (auto &light: point_lights) {
		Point3d light_direction = light.position - point;
		intensity += Directionintensity(light, point, light_direction,
				normal, view_angle, specular, scene, 1);
	}

	for (auto &light: directional_lights) {
		intensity += Directionintensity(light, point, light.direction,
				normal, view_angle, specular, scene, std::numeric_limits<double>::infinity());
	}

	return intensity;
}

double Lights::Directionintensity(Light &light, Point3d point,
		Point3d light_direction, Point3d normal,
		Point3d view_angle, double specular,
		Scene &scene, double t_max) {
	double intensity = 0;

	// Shadow check
	std::pair<Sphere *, double> closest = scene.Closestintersection(point, light_direction, 0.001, t_max);
	Sphere *shadow_sphere = closest.first;
	double closest_t = closest.second;

	if (shadow_sphere != nullptr) {
		return 0;
	}

	// Diffuse
	double dot_vectors = dot(light_direction, normal);
	if (dot_vectors > 0) {
		intensity += light.intensity * dot_vectors / (light_direction.length() * normal.length());
	}

	// Specular
	if (specular != -1) {
		Point3d reflected_direction = ReflectRay(light_direction, normal);
		double r_dot_v = dot(reflected_direction, view_angle);
		if (r_dot_v > 0) {
			intensity += light.intensity * std::pow((r_dot_v / (reflected_direction.length() * view_angle.length())), specular);
		}
	}

	return intensity;
}



std::pair<Sphere *, double> Scene::Closestintersection(Point3d origin, Point3d direction,
		double t_min, double t_max) {
	double closest_t = std::numeric_limits<double>::infinity();
	Sphere *closest_sphere = nullptr;

	for (auto &sphere: spheres) {
		std::pair<double, double> intersections = sphere.intersectRay(origin, direction);
		double t1 = intersections.first;
		double t2 = intersections.second;
		if (t_min < t1  && t1 < t_max && t1 < closest_t) {
			closest_t = t1;
			closest_sphere = &sphere;
		}
		if (t_min < t2 && t2 < t_max && t2 < closest_t) {
			closest_t = t2;
			closest_sphere = &sphere;
		}
	}

	return std::make_pair(closest_sphere, closest_t);
}


void Camera::Render (Scene &scene) {
	int64_t min_x = -canvas.width / 2;
	int64_t max_x = canvas.width / 2;
	int64_t min_y = -canvas.height / 2;
	int64_t max_y = canvas.height / 2;
	for (int64_t x = min_x; x < max_x; x++) {
		for (int64_t y = min_y; y < max_y; y++) {
			Point2d canvas_coord(x, y);

			Point3d D = viewport.CanvasToViewport(canvas_coord, canvas.width, canvas.height);
			Color color = TraceRay(position, D, viewport.distance, 
					std::numeric_limits<double>::infinity(), scene, 3);
			canvas.PutPixel(canvas_coord, color);
		}
		if (x % 10 == 0) {
			std::cout << "Rendering line " << x << "\n";
			canvas.Draw();
		}
	}
}

const Color BACKGROUND_COLOR = Color(0, 0, 0);

Color TraceRay(Point3d origin, Point3d direction,
		double t_min, double t_max, Scene &scene,
		int recursion_depth) {

	std::pair<Sphere *, double> closest = scene.Closestintersection(origin, direction, t_min, t_max);
	Sphere *closest_sphere = closest.first;
	double closest_t = closest.second;

	if (closest_sphere == nullptr) {
		return BACKGROUND_COLOR;
	}

	// Compute local color
	Point3d collision_point = origin + closest_t * direction;
	Point3d normal = collision_point - closest_sphere->center;
	normal = normal / normal.length();
	Color local_color = closest_sphere->color.mul((scene.lights.ComputeLighting(
				collision_point, normal,
				-direction, closest_sphere->specular, scene)));

	// If this sphere is not reflective or we reach the recursion limit, return
	double reflective = closest_sphere->reflective;
	if (recursion_depth < 0 || reflective <= 0) {
		return local_color;
	}

	// Compute reflected color
	Point3d reflected_ray = ReflectRay(-direction, normal);

	Color reflected_color = TraceRay(collision_point, reflected_ray,
			0.001, std::numeric_limits<double>::infinity(), scene,
			recursion_depth - 1);

	return local_color.mul(1 - reflective)
		+ reflected_color.mul(reflective);
}
