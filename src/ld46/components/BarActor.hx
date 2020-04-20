package ld46.components;

import ceramic.Quad;
import ceramic.Color;
import ceramic.Visual;

class BarActor extends Visual {
	var whiteBG:Quad;
	var blackBG:Quad;
	var background:Quad;
	var foreground:Quad;

	/**
	 * should be between 0 and 1.
	 */
	public var value:Float = 1;

	public var whiteMargin:Float = 2;
	public var blackMargin:Float = 3;

	public function new(bgColor:Color, fgColor:Color, initialValue:Float = 1) {
		super();
		whiteBG = new Quad();
		blackBG = new Quad();
		background = new Quad();
		foreground = new Quad();

		whiteBG.color = Color.WHITE;
		add(whiteBG);
		blackBG.color = Color.BLACK;
		add(blackBG);
		background.color = bgColor;
		add(background);
		foreground.color = fgColor;
		add(foreground);

		whiteBG.depth = 7;
		blackBG.depth = 8;
		background.depth = 9;
		foreground.depth = 10;

		this.value = initialValue;
	}

	public function refresh() {
		whiteBG.size(this.width, this.height);
		var m = whiteMargin;
		blackBG.pos(m, m);
		blackBG.size(this.width - m * 2, this.height - m * 2);
		m = whiteMargin + blackMargin;
		background.pos(m, m);
		background.size(this.width - m * 2, this.height - m * 2);
		foreground.pos(m, m);
		foreground.size((this.width - m * 2) * value, this.height - m * 2);
	}
}
