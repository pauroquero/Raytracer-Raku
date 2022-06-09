#!/usr/bin/env raku
use v6.d;
use lib '.';

use Common;
use CanvasSDL;
use Shapes;
use SceneElems;

my $size = 1000;
my $canvas = Canvas.new(height => $size, width => $size);

$canvas.Initialize();

my $scene = Scene.new(spheres => [
    Sphere.new(
            center => Point3d.new(x => 0.0.Num, y => -1.0.Num, z => 3.0.Num),
            radius => 1.0.Num,
            color => Color.new(r => 255, g => 0, b => 0), # Red
            specular => 500.Num, # shiny
            ),
    Sphere.new(
            center => Point3d.new(x => 2.0.Num, y => 0.0.Num, z => 4.0.Num),
            radius => 1.0.Num,
            color => Color.new(r => 0, g => 0, b => 255), # Blue
            specular => 500.Num, # shiny
            ),
    Sphere.new(
            center => Point3d.new(x => -2.0.Num, y => 0.0.Num, z => 4.0.Num),
            radius => 1.0.Num,
            color => Color.new(r => 0, g => 255, b => 0), # Green
            specular => 10.Num, # Somewhat shiny
            ),
    Sphere.new(
            center => Point3d.new(x => 0.Num, y => -5001.Num, z => 0.Num),
            radius => 5000.Num,
            color => Color.new(r => 255, g => 255, b => 0), # Yellow
            specular => 1000.Num # Very shiny
            ),
    Sphere.new(
            center => Point3d.new(x => 0.Num, y => 0.2.Num, z => 3.Num),
            radius => 0.25.Num,
            color => Color.new(r => 255, g => 0, b => 200), # Yellow
            specular => -1.Num # Not shiny
            ),
],
        lights => Lights.new(
                ambient_lights => [
                        AmbientLight.new(intensity => 0.2.Num)
                ],
                point_lights => [
                        PointLight.new(intensity => 0.6.Num,
                                position => Point3d.new(x => 2.Num, y => 1.Num, z => 0.Num))
                ],
                directional_lights => [
                        DirectionalLight.new(intensity => 0.2.Num,
                                direction => Point3d.new(x => 1.Num, y => 4.Num, z => 4.Num))
                ],
                )
        );

my $viewport = Viewport.new(canvas => $canvas);

my $camera = Camera.new(
        viewport => $viewport,
        canvas => $canvas,
        position => Point3d.new(x => 0.0.Num, y => 0.0.Num, z => 0.0.Num),
        );

$camera.Render($scene);

$canvas.Draw();
sleep(50);

$canvas.Destroy();

say "Finished";