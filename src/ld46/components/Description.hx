package ld46.components;

import ceramic.Color;
import ceramic.Quad;
import ceramic.Text;

class Description extends Quad {
	public var text:Text;
	public var bg:Quad;

	public function new(textStr:String) {
		super();
		bg = new Quad();
		bg.color = Color.BLACK;
		bg.alpha = 0.8;

		bg.anchor(0, 0);
		bg.pos(0, 0);

		text = new Text();
		text.anchor(0, 0);
		text.pos(20, 20);

		text.content = textStr;
		text.fitWidth = bg.width - 40;

		add(bg);
		add(text);

		this.anchor(1, 1);

		HotLoader.instance.onReload(this, loadContent);
		loadContent();
	}

	function loadContent() {
		var width = Data.configs.get(DescWidth).sure().value;
		var height = Data.configs.get(DescHeight).sure().value;
		this.size(width, height);
		bg.size(width, height);
		text.size(width - 40, height - 40);
	}
}
