package;

import nape.shape.Polygon;
import ceramic.Text;
import ceramic.Point;
import ceramic.Visual;
import luxe.Camera;
import nape.dynamics.InteractionFilter;
import ceramic.KeyCode;
import ceramic.Mesh;
import nape.constraint.PivotJoint;
import ceramic.NapePhysicsBodyType;
import nape.geom.Vec2;
import nape.phys.Material;
import ceramic.Entity;
import ceramic.Color;
import ceramic.Quad;
import ceramic.InitSettings;
import ceramic.Shortcuts.*;

class Project extends Entity {
	var tableBaseFilter = new InteractionFilter(1, 1);
	var tablePivotsFilter = new InteractionFilter(2, 2);
	var tablePieces = new InteractionFilter(4, 4);

	function new(settings:InitSettings) {
		super();

		settings.antialiasing = 4;
		settings.background = Color.GRAY;
		settings.targetWidth = 1680;
		settings.targetHeight = 1000;
		settings.scaling = FILL;

		app.onceReady(this, ready);
	} // new

	function ready() {
		// Hello World?
		//
		var material = new Material(1, 5);
		var handJoint = new PivotJoint(app.nape.space.world, null, Vec2.weak(), Vec2.weak());

		var camera = new Visual();
		camera.pos(screen.width * 0.5, screen.height * 0.5);

		var tableFeets = new Quad();
		var connectorTL = new Quad();
		var connectorTLPivot:PivotJoint;
		var connectorTR = new Quad();
		var connectorTRPivot:PivotJoint;
		var connectorBL = new Quad();
		var connectorBLPivot:PivotJoint;
		var connectorBR = new Quad();
		var connectorBRPivot:PivotJoint;

		var shape = new Mesh();

		var quad1 = new Quad();
		var quad2 = new Quad();
		var quad3 = new Quad();

		var pointer = new Quad();
		var strokeBuilder = new polyline.Stroke();
		var line = new Mesh();
		var mousePoint = Vec2.get(0, 0);

		camera.add(tableFeets);
		camera.add(quad1);
		camera.add(quad2);
		camera.add(quad3);
		camera.add(pointer);
		camera.add(line);
		camera.add(connectorTL);
		camera.add(connectorTR);
		camera.add(connectorBL);
		camera.add(connectorBR);
		camera.add(shape);

		function reset() {
			handJoint.space = app.nape.space;
			handJoint.active = false;
			handJoint.stiff = false;

			tableFeets.size(550, 700);
			tableFeets.anchor(0.5, 0.5);
			tableFeets.color = Color.BROWN;
			tableFeets.pos(0, 0);
			tableFeets.initNapePhysics(NapePhysicsBodyType.KINEMATIC);
			tableFeets.nape.body.setShapeFilters(tableBaseFilter);
			var t = new Text();
			t.id = "text";
			tableFeets.add(t);

			connectorTL.size(30, 300);
			connectorTL.anchor(0.5, 0.5);
			connectorTL.pos(-tableFeets.width * 0.5 + 15, -tableFeets.height * 0.5 + 15);
			connectorTL.initNapePhysics(NapePhysicsBodyType.DYNAMIC);
			connectorTL.nape.body.setShapeFilters(tablePivotsFilter);
			if (connectorTLPivot != null)
				connectorTLPivot.space = null;
			connectorTLPivot = new PivotJoint(connectorTL.nape.body, tableFeets.nape.body, Vec2.weak(),
				tableFeets.nape.body.worldPointToLocal(Vec2.weak(-tableFeets.width * 0.5 + 15, -tableFeets.height * 0.5 + 15)));
			connectorTLPivot.space = app.nape.space;
			t = new Text();
			t.id = "text";
			connectorTL.add(t);

			connectorBR.size(30, 300);
			connectorBR.anchor(0.5, 0.5);
			connectorBR.pos(tableFeets.width * 0.5 - 15, tableFeets.height * 0.5 - 15);
			connectorBR.initNapePhysics(NapePhysicsBodyType.DYNAMIC);
			connectorBR.nape.body.setShapeFilters(tablePivotsFilter);
			if (connectorBRPivot != null)
				connectorBRPivot.space = null;
			connectorBRPivot = new PivotJoint(connectorBR.nape.body, tableFeets.nape.body, Vec2.weak(),
				tableFeets.nape.body.worldPointToLocal(Vec2.weak(tableFeets.width * 0.5 - 15, tableFeets.height * 0.5 - 15)));
			connectorBRPivot.space = app.nape.space;

			connectorTR.size(30, 300);
			connectorTR.anchor(0.5, 0.5);
			connectorTR.pos(tableFeets.width * 0.5 - 15, -tableFeets.height * 0.5 + 15);
			connectorTR.initNapePhysics(NapePhysicsBodyType.DYNAMIC);
			connectorTR.nape.body.setShapeFilters(tablePivotsFilter);
			if (connectorTRPivot != null)
				connectorBRPivot.space = null;
			connectorTRPivot = new PivotJoint(connectorTR.nape.body, tableFeets.nape.body, Vec2.weak(),
				tableFeets.nape.body.worldPointToLocal(Vec2.weak(tableFeets.width * 0.5 - 15, -tableFeets.height * 0.5 + 15)));
			connectorTRPivot.space = app.nape.space;

			connectorBL.size(30, 300);
			connectorBL.anchor(0.5, 0.5);
			connectorBL.pos(-tableFeets.width * 0.5 + 15, tableFeets.height * 0.5 - 15);
			connectorBL.initNapePhysics(NapePhysicsBodyType.DYNAMIC);
			connectorBL.nape.body.setShapeFilters(tablePivotsFilter);
			if (connectorBLPivot != null)
				connectorBRPivot.space = null;
			connectorBLPivot = new PivotJoint(connectorBL.nape.body, tableFeets.nape.body, Vec2.weak(),
				tableFeets.nape.body.worldPointToLocal(Vec2.weak(-tableFeets.width * 0.5 + 15, tableFeets.height * 0.5 - 15)));
			connectorBLPivot.space = app.nape.space;

			shape.color = Color.RED;
			shape.vertices = [
				  0,   0,
				800,   0,
				800, 940,
				400, 940,
				400, 300,
				  0, 300
			];
			shape.indices = [for (i in 0...shape.vertices.length) i];
			// shape.initNapePhysics(NapePhysicsBodyType.DYNAMIC);

			quad1.color = Color.RED;
			quad1.depth = 2;
			quad1.size(50, 50);
			quad1.anchor(0, 0);
			quad1.pos(screen.width * 0.5, screen.height * 0.5);
			quad1.initNapePhysics(NapePhysicsBodyType.DYNAMIC);
			quad1.nape.body.setShapeFilters(tablePieces);

			quad2.depth = 1;
			quad2.color = Color.YELLOW;
			quad2.size(150, 150);
			quad2.anchor(0.5, 0.5);
			quad2.pos(screen.width * 0.5, screen.height * 0.5 + 150);
			quad2.rotation = 5;
			quad2.initNapePhysics(NapePhysicsBodyType.DYNAMIC);
			quad2.nape.body.setShapeFilters(tablePieces);

			quad3.depth = 1;
			quad3.color = Color.ORANGE;
			quad3.size(50, 50);
			quad3.anchor(1, 1);
			quad3.pos(screen.width * 0.5, screen.height * 0.5 - 150);
			quad3.rotation = 10;
			quad3.initNapePhysics(NapePhysicsBodyType.DYNAMIC, null, null, material);
			quad3.nape.body.setShapeFilters(tablePieces);

			pointer.depth = 999;
			pointer.color = Color.WHITE;
			pointer.size(5, 5);
			pointer.anchor(0.5, 0.5);
			pointer.rotation = 45;

			strokeBuilder.thickness = 5;
			strokeBuilder.cap = BUTT;
			strokeBuilder.join = MITER;
			strokeBuilder.miterLimit = 2;

			line.colors = [0xFFFFFFFF];
			strokeBuilder.build([0, 0, 250, 250], line.vertices, line.indices);
		}
		reset();

		app.onKeyDown(this, key -> {
			if (key.keyCode == KeyCode.KEY_R) {
				reset();
			}
		});
		screen.onPointerMove(this, info -> {
			quad1.color = Color.RED;
			for (body in app.nape.space.bodiesUnderPoint(mousePoint)) {
				if (!body.isDynamic()) {
					continue;
				}
				quad1.color = Color.BLUE;
			}
		});
		screen.onPointerDown(this, info -> {
			for (body in app.nape.space.bodiesUnderPoint(mousePoint)) {
				if (!body.isDynamic()) {
					continue;
				}

				handJoint.body2 = body;
				handJoint.anchor2.set(body.worldPointToLocal(mousePoint, true));

				// Enable hand joint!
				handJoint.active = true;

				break;
			}
		});

		screen.onPointerUp(this, info -> {
			handJoint.active = false;
		});

		app.onPreUpdate(this, function(delta) {
			mousePoint.dispose();
			var p:Point = new Point();
			camera.screenToVisual(screen.pointerX, screen.pointerY, p);
			mousePoint = Vec2.get(p.x, p.y);
			if (handJoint.active) {
				handJoint.anchor1.setxy(mousePoint.x, mousePoint.y);
				pointer.pos(handJoint.anchor1.x, handJoint.anchor1.y);
				pointer.visible = true;
				line.visible = true;
				strokeBuilder.build([
					handJoint.anchor1.x,
					handJoint.anchor1.y,
					handJoint.anchor2.x + handJoint.body2.position.x,
					handJoint.anchor2.y + handJoint.body2.position.y
				], line.vertices, line.indices);
			} else {
				pointer.visible = false;
				line.visible = true;
			}

			for (visual in camera.children) {
				var t:Text = cast tableFeets.childWithId("text");
				if (t != null) {
					t.content = Math.round(tableFeets.x) + ',' + Math.round(tableFeets.y);
				}
			}
		});
	} // ready
}
