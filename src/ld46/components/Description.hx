package ld46.components;

import ceramic.Color;
import ceramic.Quad;
import ceramic.Text;

class Description extends Quad {
	public var text:Text;
	public var bg:Quad;
	public var descWidth:Int = -1;
	public var descHeight:Int = -1;

	public function new(textStr:String, width:Int = -1, heigth:Int = -1) {
		super();
		descWidth = width;
		descHeight = heigth;
		bg = new Quad();
		bg.color = Color.BLACK;
		bg.alpha = 0.75;

		bg.anchor(0, 0);
		bg.pos(0, 0);

		text = new Text();
		text.anchor(0, 0);
		text.pos(20, 20);

		add(bg);
		add(text);

		this.anchor(1, 1);

		// HotLoader.instance.onReload(this, refresh);
		refresh();
	}

	public function refresh() {
		var w = descWidth > 0 ? descWidth : Data.configs.get(DescWidth).sure().value;
		var h = descHeight > 0 ? descHeight : Data.configs.get(DescHeight).sure().value;
		this.size(w, h);
		bg.size(w, h);
		text.size(w - 40, h - 40);
		text.fitWidth = bg.width - 40;
	}
}
