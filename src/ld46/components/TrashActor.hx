package ld46.components;

import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;

class TrashActor extends Quad {
	private var assets:Assets;

	public function new(assets:Assets) {
		super();
		this.assets = assets;
		this.texture = assets.texture(Images.PRELOAD__TRASH);

		this.onPointerOver(this, evt -> {
			if (evt.buttonId > 0)
				this.scale(1.1, 1.1);
		});
		this.onPointerOut(this, evt -> {
			this.scale(1, 1);
		});
	}
}
