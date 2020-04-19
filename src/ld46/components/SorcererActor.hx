package ld46.components;

import ceramic.Images;
import ceramic.Assets;
import ld46.model.Sorcerer;
import ceramic.Quad;

class SorcererActor extends Quad {
	public var sdata:Sorcerer;
	public var items:Array<SorcererItemActor>;

	private var assets:Assets;

	public function new(assets:Assets, sdata:Sorcerer) {
		super();
		this.sdata = sdata;
		this.assets = assets;
		this.items = new Array<SorcererItemActor>();
		this.texture = assets.texture(Images.PRELOAD__DUMMY);

		for (item in sdata.items) {
			var actor = new SorcererItemActor(assets, item);
			items.push(actor);
			this.add(actor);
		}
	}

	public function udpate() {
		this.pos(sdata.x, sdata.y);
		for (actor in items) {
			actor.update();
		}
	}
}
