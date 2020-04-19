package ld46.components;

import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;

class NextRoundButton extends Quad {
	private var assets:Assets;

	public function new(assets:Assets) {
		super();
		this.assets = assets;
		this.texture = assets.texture(Images.PRELOAD__NEXT_ROUND_BUTTON);
		this.anchor(0.5, 0.5);
        this.pos(40 + this.width / 2, 40 + this.height / 2);

        this.onPointerOver(this, evt -> {
            this.scale(1.1, 1.1);
        });
        this.onPointerOut(this, evt -> {
            this.scale(1, 1);
        });
	}
}
