package ld46.fx;

import ceramic.Timer;
import ceramic.Easing;
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
class AttackFX extends Visual {
	var effect:Quad;

	/**
	 * should be between 0 and 1.
	 */
	public var value:Float = 1;

	public var blackMargin:Float = 0.3;
	public var whiteMargin:Float = 0.15;

	public function new(fromX:Float, fromY:Float, toX:Float, toY:Float, damage:Float, duration:Float = 0.35, autodestroy = true) {
		super();

		effect = new Quad();
		effect.color = Color.PURPLE;
		effect.width = 5 + damage * 0.1;
		effect.height = 5 + damage * 0.1;
		effect.anchor(0.5, 0.5);
		effect.skew(5 + 50 * Math.random(), 5 + 50 * Math.random());
		add(effect);

		this.alpha = 0.75;

		effect.pos(fromX, fromY);
		var tween = effect.transition(Easing.QUAD_EASE_OUT, duration, props -> {
			props.pos(toX, toY);
		});
		if (tween != null) {
			tween.onUpdate(this, (value, time) -> {
				effect.depth = 1000 + effect.y - Data.configs.get(MissilesHeight).sure().value;
			});
			tween.onComplete(this, () -> {
				if (autodestroy) {
					effect.destroy();
					this.destroy();
				}
					
			});
		} else {
			effect.destroy();
			this.destroy();
		}
	}
}
