package ld46.components;

import ceramic.Assets;
import ld46.model.SorcererItem;
import ceramic.Quad;

class SorcererItemActor extends Quad {

    public var item:SorcererItem;

    private var assets:Assets;

    public function new(item:SorcererItem, assets:Assets) {
        super();
        this.item = item;
        this.assets = assets;
        this.texture = assets.texture(item.itemData.image);
    }

    public function update() {

    }
    
}