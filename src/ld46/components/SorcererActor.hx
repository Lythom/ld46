package ld46.components;

import ceramic.Assets;
import ld46.model.Sorcerer;
import ceramic.Quad;

class SorcererActor extends Quad {
	public var sdata:Sorcerer;

	private var assets:Assets;

	public function new(sdata:Sorcerer, assets:Assets) {
		super();
        this.sdata = sdata;
        this.assets = assets;
		for (item in sdata.items) {
			this.add(new SorcererItemActor(item, assets));
		}
	}

	public function udpate() {}
}
