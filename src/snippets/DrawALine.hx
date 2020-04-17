package snippets;

import ceramic.Images;
import ceramic.Point;
import ceramic.KeyCode;
import ceramic.Mesh;
import ceramic.Entity;
import ceramic.Color;
import ceramic.InitSettings;
import ceramic.Shortcuts.*;

class DrawALine extends Entity {
	var strokeBuilder:polyline.Stroke;
	var line:Mesh;
	var line2:Mesh;

	var p:Point;
	var assets:ceramic.Assets;
	var pointer = new ceramic.Quad();

	function new(settings:InitSettings) {
		super();

		settings.antialiasing = 1;
		settings.background = Color.GRAY;
		settings.targetWidth = 1680;
		settings.targetHeight = 1000;
		settings.scaling = FILL;

		app.onceReady(this, ready);
	} // new

	function ready() {

		assets = new ceramic.Assets();
		// assets.addImage(Images.PRELOAD__PIECE_BOTTOM);
		// assets.addImage(Images.PRELOAD__PIECE_TOP);
		// assets.addImage(Images.PRELOAD__PIVOTER_COURT);
		// assets.addImage(Images.PRELOAD__PIVOTER_LONG);
		// assets.addImage(Images.PRELOAD__TABLE_BASE);
		// assets.addImage(Texts.PRELOAD__OGMOLEVEL);
		assets.addAll(~/^preload\//);
		assets.onceComplete(this, start);
		assets.load();
	}

	function start(ready:Bool) {
		strokeBuilder = new polyline.Stroke();
		line = new Mesh();
		line2 = new Mesh();

		p =  {
			x: screen.width * 0.5, 
			y: screen.height * 0.5
		};

		pointer.texture = assets.texture(Images.PRELOAD__PIVOTER_COURT);
		pointer.size(20, 20);
		pointer.depth = 999;
		pointer.anchor(0.5, 0.5);
		pointer.rotation = 45;
		

		function reset() {
			strokeBuilder.thickness = 5;
			strokeBuilder.cap = BUTT;
			strokeBuilder.join = MITER;
			strokeBuilder.miterLimit = 2;

			line.colors = [0xFFFFFFFF];
			line2.colors = [0xFFFF25FF];
		}
		reset();

		app.onUpdate(this, delta -> {
			pointer.pos(screen.pointerX, screen.pointerY);
			strokeBuilder.build([p.x, p.y, screen.pointerX, screen.pointerY], line2.vertices, line2.indices);
		});

		var dragOrigin:Point = null;
		app.onKeyDown(this, key -> {
			if (key.keyCode == KeyCode.KEY_R) {
				reset();
			}
		});
		screen.onPointerMove(this, info -> {
			if (dragOrigin != null) {
				var diff = new Point(info.x - dragOrigin.x, info.y - dragOrigin.y);
				strokeBuilder.build([p.x, p.y, diff.x, diff.y], line.vertices, line.indices);
			}
		});
		screen.onPointerDown(this, info -> {
			dragOrigin = {
				x: info.x,
				y: info.y
			};
		});

		screen.onPointerUp(this, info -> {
			dragOrigin = null;
		});
	}
}
