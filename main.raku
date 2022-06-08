#!/usr/bin/env raku
use v6.d;
use lib '.';

use CanvasSDL;

my $canvas = Canvas.new();

$canvas.Initialize();

$canvas.PutPixel(0, 0, Color.new(r => 255, g => 0, b => 0));

$canvas.Draw();
sleep(5);

$canvas.Destroy();