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
		bg.size(320, 400);
		bg.anchor(0, 0);
		bg.pos(0, 0);

		text = new Text();
		text.anchor(0, 0);
		text.pos(20, 20);
		text.size(280, 360);
		text.content = textStr;
		text.fitWidth = 280;

		add(bg);
		add(text);

		this.size(320, 400);
		this.anchor(1, 1);
	}
}
