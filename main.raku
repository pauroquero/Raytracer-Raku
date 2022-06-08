#!/usr/bin/env raku
use v6.d;
use lib '.';

use Common;
use CanvasSDL;
use Shapes;
use SceneElems;

my $size = 300;
my $canvas = Canvas.new(height => $size, width => $size);

$canvas.Initialize();

my $scene = Scene.new(spheres => [
    Sphere.new(
            center => Point3d.new(x => 0.0.Num, y => -1.0.Num, z => 3.0.Num),
            radius => 1.0.Num,
            color => Color.new(r => 255, g => 0, b => 0),
            ),
    Sphere.new(
            center => Point3d.new(x => 2.0.Num, y => 0.0.Num, z => 4.0.Num),
            radius => 1.0.Num,
            color => Color.new(r => 0, g => 0, b => 255),
            ),
    Sphere.new(
            center => Point3d.new(x => -2.0.Num, y => 0.0.Num, z => 4.0.Num),
            radius => 1.0.Num,
            color => Color.new(r => 0, g => 255, b => 0),
            ),
]);

my $viewport = Viewport.new(canvas => $canvas);

my $camera = Camera.new(
        viewport => $viewport,
        canvas => $canvas,
        position => Point3d.new(x => 0.0.Num, y => 0.0.Num, z => 0.0.Num),
        );

$camera.Render($scene);

$canvas.Draw();
sleep(5);

$canvas.Destroy();

say "Finished";