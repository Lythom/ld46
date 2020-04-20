package ld46.fx;

import ceramic.BitmapFont;
import ceramic.Assets;
import ceramic.Fonts;
import ceramic.Text;
import ceramic.Quad;
import ceramic.Color;
import ceramic.Visual;
import ceramic.Shortcuts.*;

/**
 * FX will autodestroy when finished.
 */
class AnnounceFX extends Visual {
	var blackBG:Quad;
	var whiteBG:Quad;
	var text:Text;

	/**
	 * should be between 0 and 1.
	 */
	public var value:Float = 1;

	public var blackMargin:Float = 0.3;
	public var whiteMargin:Float = 0.15;

	public function new(content:String, font:BitmapFont, textSize:Int = 72, duration:Int = 2, autodestroy = true) {
		super();

		text = new Text();
		text.font = font;
		text.color = Color.BLACK;
		text.pointSize = textSize;
		text.width = screen.width;
		text.content = content;
		text.anchor(0.5, 0.5);
		text.computeContent();

		blackBG = new Quad();
		blackBG.color = Color.BLACK;
		blackBG.width = screen.width;
		blackBG.height = text.height + text.height * blackMargin + text.height * whiteMargin;
		blackBG.anchor(0.5, 0.5);
		blackBG.skew(15, 0);
		blackBG.alpha = 0.7;

		whiteBG = new Quad();
		whiteBG.color = Color.WHITE;
		whiteBG.width = screen.width;
		whiteBG.height = text.height + text.height * whiteMargin;
		whiteBG.anchor(0.5, 0.5);
		whiteBG.skew(15, 0);
		whiteBG.alpha = 0.7;

		this.alpha = 0.7;

		add(text);
		add(blackBG);
		add(whiteBG);

		blackBG.depth = 2;
		whiteBG.depth = 3;
		text.depth = 4;

		this.depth = 999999;

		// http://tweenx.spheresofa.net/core/custom/#%7B%22time%22%3A2%2C%22easing%22%3A%5B%22Op%22%2C%5B%22Simple%22%2C%5B%22Standard%22%2C%22Quint%22%2C%22OutIn%22%5D%5D%2C%5B%22Op%22%2C%5B%22Simple%22%2C%22Linear%22%5D%2C%5B%22Mix%22%2C0.15%5D%5D%5D%7D
		var easing = ceramic.Easing.CUSTOM(rate -> tweenxcore.Tools.FloatTools.mixEasing(rate, tweenxcore.Tools.Easing.quintOutIn,
			tweenxcore.Tools.Easing.linear, 0.08));

		this.tween(easing, duration, 0, 1, (val, _) -> {
			var start = screen.width + blackBG.width * 0.5;
			var end = 0 - blackBG.width * 0.5;
			blackBG.pos(start + (end - start) * val, screen.height * 0.5);
			text.pos(start + (end - start) * val, screen.height * 0.5);
			whiteBG.pos(end + (start - end) * val, screen.height * 0.5);
		}).onComplete(this, () -> {
			if (autodestroy)
				this.destroy();
		});
	}
}
