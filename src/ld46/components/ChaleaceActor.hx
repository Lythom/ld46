package ld46.components;

import ld46.model.Chaleace;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;

class ChaleaceActor extends Quad {
	public var cData:Chaleace;

	private var assets:Assets;

	public function new(assets:Assets, cData:Chaleace) {
		super();
		this.cData = cData;
		this.assets = assets;
		this.texture = assets.texture(Images.PRELOAD__DUMMY);
		
	}

	public function udpate() {
		this.pos(cData.x, cData.y);
	}
}
