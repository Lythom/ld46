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
    @observe public var value:Float = 1;

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

        this.value = initialValue;

        autorun(() -> {
            whiteBG.size(this.width, this.height);
            blackBG.pos(5, 5);
            blackBG.size(this.width - 10, this.height - 10);
            background.pos(10, 10);
            background.size(this.width - 20, this.height - 20);
            foreground.pos(10, 10);
            foreground.size((this.width - 20) * value, this.height - 20);
        });
	}
}
