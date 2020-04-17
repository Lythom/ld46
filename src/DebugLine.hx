package;

using Lambda;
using NullTools;

@:nullSafety(Strict)
class DebugLine {
	public var body:nape.phys.Body;
	public var line:ceramic.Mesh;

	var strokeBuilder:polyline.Stroke;

	public function new(body:nape.phys.Body) {
		this.body = body;
		line = new ceramic.Mesh();
		line.colors = [0xFFFFFFFF];
		line.depth = 9999;
		strokeBuilder = new polyline.Stroke();
		strokeBuilder.thickness = 2;
		strokeBuilder.cap = BUTT;
		strokeBuilder.join = MITER;
		strokeBuilder.miterLimit = 2;
	}

	public function redraw() {
		var flatten = new Array<Float>();

        @:nullSafety(Off)
		for (shape in body.shapes) {
			shape.sure();
			var shapeArray = shape.castPolygon.worldVerts.flatMap(vec2 -> [vec2.x, vec2.y]);
			flatten = flatten.concat(shapeArray);
			flatten.push(shapeArray[0]);
			flatten.push(shapeArray[1]);
		}
		this.strokeBuilder.build(flatten, line.vertices, line.indices);
	}
}
