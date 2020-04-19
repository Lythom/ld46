package ld46.components;

import ceramic.Assets;
import ld46.model.SorcererItem;
import ceramic.Quad;

class SorcererItemActor extends Quad {
	public var item:SorcererItem;

	private var assets:Assets;

	public function new(assets:Assets, item:SorcererItem) {
		super();
		this.item = item;
		this.assets = assets;
		HotLoader.instance.onReload(this, loadContent);
		loadContent();
	}

	public function loadContent() {
		this.texture = assets.textureFromFile(item.itemData.image);
	}

	public function update() {}
}
