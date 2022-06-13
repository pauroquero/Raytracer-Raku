#include <iostream>
#include <vector>
#include <chrono>
#include <thread>

#include "Common.h"
#include "CanvasSDL.h"
#include "Shapes.h"
#include "SceneElems.h"

using namespace std::chrono_literals;

const int size = 1000;

int main() {
	Canvas canvas = Canvas{size, size};

	canvas.Initialize();
	Lights lights(
			std::vector<AmbientLight>{
			AmbientLight(0.2)
			},
			std::vector<PointLight>{
			PointLight(0.6,
					Point3d(2, 1, 0))
			},
			std::vector<DirectionalLight>{
			DirectionalLight(0.2,
					Point3d(1, 4, 4))
			}
		     );

	Scene scene = Scene{std::vector<Sphere>{
		Sphere(
				Point3d(0., -1, 3.0),
				1.0,
				Color(255, 0, 0), // Red
				500, // shiny
				0.2 // A bit reflective
		      ),
			Sphere(
					Point3d(2.0, 0.0, 4.0),
					1.0,
					Color(0, 0, 255), // Blue
					500, // shiny
					0.3 // A bit more reflective
			      ),
			Sphere(
					Point3d(-2.0, 0.0, 4.0),
					1.0,
					Color(0, 255, 0), // Green
					10, // Somewhat shiny
					0.4 // Even more reflective
			      ),
			Sphere(
					Point3d(0, -5001, 0),
					5000,
					Color(255, 255, 0), // Yellow
					1000, // Very shiny
					0.4 // Half reflective
			      ),
			Sphere(
					Point3d(0, 0.2, 3),
					0.25,
					Color(255, 0, 200), // Yellow
					-1, // Not shiny
					0 // Not reflective
			      ),
			},
	      lights
	};

	Viewport viewport;

	Camera camera(viewport, canvas,
			Point3d(0.0, 0.0, 0.0));

	camera.Render(scene);

	canvas.Draw();
	//std::this_thread::sleep_for(2000ms);


	canvas.Destroy();

	std::cout << "Finished\n";
}
