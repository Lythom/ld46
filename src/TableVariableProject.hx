package;

import luxe.importers.obj.Reader;
import haxe.ds.StringMap;
import ceramic.Texture;
import ceramic.Images;
import ceramic.ImageAsset;
import ceramic.Assets;
import ceramic.Texts;
import ceramic.Asset;
import nape.geom.MarchingSquares;
import nape.geom.AABB;
import nape.geom.IsoFunction;
import ceramic.Triangulate;
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

using Lambda;
using StringTools;

class TableVariableProject extends Entity {
	var assets:Assets;

	var tableBaseFilter = new InteractionFilter(1, 1);
	var tablePivotsFilter = new InteractionFilter(2, 2);
	var tablePieces = new InteractionFilter(4, 4);

	function new(settings:InitSettings) {
		super();
		settings.antialiasing = 4;
		settings.background = Color.GRAY;
		settings.targetWidth = 1280;
		settings.targetHeight = 720;
		settings.scaling = FILL;

		app.onceReady(this, ready);
	} // new

	function ready() {
		assets = new Assets();
		assets.watchDirectory(ceramic.macros.DefinesMacro.getDefine('assets_path'));
		assets.addAll(~/^preload\//);
		assets.onceComplete(this, start);
		assets.load();
	}

	function getTextureFromName(name:String):Texture {
		if (name.contains("base"))
			return assets.texture(Images.PRELOAD__TABLE_BASE);
		if (name.contains("bottom"))
			return assets.texture(Images.PRELOAD__PIECE_BOTTOM);
		if (name.contains("top"))
			return assets.texture(Images.PRELOAD__PIECE_TOP);
		if (name.contains("court"))
			return assets.texture(Images.PRELOAD__PIVOTER_COURT);
		if (name.contains("long"))
			return assets.texture(Images.PRELOAD__PIVOTER_LONG);

		return null;
	}

	function getFilterFromName(name:String):InteractionFilter {
		if (name.contains("base"))
			return tableBaseFilter;
		if (name.contains("bottom"))
			return tablePieces;
		if (name.contains("top"))
			return tablePieces;
		if (name.contains("court"))
			return tablePivotsFilter;
		if (name.contains("long"))
			return tablePivotsFilter;
		return null;
	}

	function start(success:Bool) {

		// new HotLoader(() -> {
		// 	var castleDBContent = assets.text(Texts.PRELOAD__CDB);
		// 	Data.load(castleDBContent);
		// });

		var text:Text = new Text();

		var handJoint = new PivotJoint(app.nape.space.world, null, Vec2.weak(), Vec2.weak());
		var mousePoint = Vec2.get(0, 0);
		var pointer = new Quad();

		var camera = new Visual();
		camera.pos(screen.width * 0.5, screen.height * 0.5);

		pointer.texture = assets.texture(Images.PRELOAD__PIVOTER_COURT);
		pointer.size(20, 20);
		pointer.depth = 999;
		pointer.anchor(0.5, 0.5);
		pointer.rotation = 45;
		camera.add(pointer);
		var objects:List<Quad> = new List<Quad>();
		var joints:List<PivotJoint> = new List<PivotJoint>();
		var debugLines:List<DebugLine> = new List<DebugLine>();

		function reset() {
			trace("do reset");
			for (quad in objects) {
				quad.nape.body.space = null;
				quad.destroy();
			}
			objects.clear();
			for (line in debugLines) {
				line.line.destroy();
			}
			debugLines.clear();

			handJoint.space = app.nape.space;
			handJoint.active = false;
			handJoint.stiff = false;

			var level = Level.create(assets.text(Texts.PRELOAD__OGMOLEVEL));

			var objectLayer = level.layers.find(l -> l.name == "main");
			for (decal in objectLayer.decals) {
				var name = decal.texture.toLowerCase();
				var object = new Quad();
				var texture:Texture = getTextureFromName(name);
				texture.asset.offReplaceTexture();
				texture.asset.onReplaceTexture(this, (_, __) -> reset());

				object.texture = texture;
				object.size(texture.width, texture.height);
				object.anchor(0.5, 0.5);
				object.pos(decal.x, decal.y);
				object.initNapePhysics(name.contains("base") ? NapePhysicsBodyType.KINEMATIC : NapePhysicsBodyType.DYNAMIC);
				object.nape.body.shapes.clear();

				var iso = new TextureIso(texture);
				var polys = MarchingSquares.run(iso.iso, iso.bounds, Vec2.weak(4, 4), 2);
				var shapeCount:Int = 0;
				for (p in polys) {
					var qolys = p.simplify(1.5).convexDecomposition(true);
					for (q in qolys) {
						var polygon = new Polygon(q);
						object.nape.body.shapes.add(polygon);
						shapeCount++;
						var dl = new DebugLine(object.nape.body);
						dl.redraw();
						camera.add(dl.line);
						debugLines.add(dl);
						q.dispose();
					}
					qolys.clear();
					p.dispose();
				}
				polys.clear();
				object.nape.body.translateShapes(Vec2.weak(-object.width * 0.5, -object.height * 0.5));
				object.nape.body.setShapeFilters(getFilterFromName(name));

				camera.add(object);
				objects.add(object);
			}

			var constraintsLayer = level.layers.find(l -> l.name == "constraints");
			for (contraint in constraintsLayer.entities) {}
		}
		reset();
		// assets.texture(Images.PRELOAD__PIECE_TOP).asset.onComplete(this, _ -> reset());

		/*

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
		 */

		var dragCameraOrigin:Point = null;
		var dragOrigin:Point = null;
		app.onKeyDown(this, key -> {
			if (key.keyCode == KeyCode.KEY_R) {
				reset();
			}
		});
		screen.onPointerMove(this, info -> {
			pointer.pos(mousePoint.x, mousePoint.y);
			if (dragCameraOrigin != null) {
				var diff = new Point(info.x - dragOrigin.x, info.y - dragOrigin.y);
				camera.pos(dragCameraOrigin.x + diff.x, dragCameraOrigin.y + diff.y);
			}
			pointer.scale(1, 1);
			for (body in app.nape.space.bodiesUnderPoint(mousePoint)) {
				if (!body.isDynamic()) {
					continue;
				}
				pointer.scale(2, 2);
				// a moveable object is under the cursor !
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
			if (!handJoint.active && dragCameraOrigin == null) {
				dragCameraOrigin = {
					x: camera.x,
					y: camera.y
				};
				dragOrigin = {
					x: info.x,
					y: info.y
				};
			}
		});

		screen.onPointerUp(this, info -> {
			handJoint.active = false;
			dragCameraOrigin = null;
			dragOrigin = null;
			pointer.scale(1, 1);
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
				pointer.scale(3, 3);
			}
		});
		app.onUpdate(this, delta -> {
			for (object in objects) {
				object.nape.body.velocity.muleq(0.9);
				object.nape.body.angularVel *= 0.9;
			}
		});
		app.onPostUpdate(this, delta -> {
			for (dl in debugLines) {
				dl.redraw();
			}
		});
		screen.onMouseWheel(this, (x, y) -> {
			camera.scale(camera.scaleX * (y > 0 ? 1.1 : 0.9), camera.scaleY * (y > 0 ? 1.1 : 0.9));
		});

		function reload() {
			text.content = Data.entities.all[0].description;
			new ceramic.Particles();
		}
		// HotLoader.instance.onReload(this, reload);
		reload();
	} // ready
}

class TextureIso {
	public var buffer:backend.UInt8Array = null;
	public var bounds:AABB;

	public function new(texture:Texture) {
		this.bounds = new AABB(0, 0, texture.width, texture.height);
		this.buffer = new ceramic.UInt8Array(Std.int(texture.width * texture.height * 4));
		app.backend.textures.fetchTexturePixels(texture.backendItem, this.buffer);
		this.buffer = this.buffer.filter((_, idx) -> idx % 4 == 3);
	}

	public function iso(x:Float, y:Float) {
		var alpha = buffer[Std.int(x + y * bounds.width)];
		return (alpha > 10 ? -1.0 : 1.0);
	}
}
