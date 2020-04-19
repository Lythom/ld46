package ld46.components;

import ceramic.Easing;
import ld46.model.SorcererItem;
import ld46.model.Shelf;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;

class ShelfActor extends Quad {
    private var assets:Assets;
    private var getItemActor:SorcererItem->SorcererItemActor;
    private var items:List<SorcererItemActor>;

    public var shelf:Shelf;
    
	public function new(assets:Assets, shelf:Shelf, getItemActor:SorcererItem->SorcererItemActor) {
        super();
        this.assets = assets;
        this.shelf = shelf;
        this.getItemActor = getItemActor;
        this.items = shelf.items.map(item -> getItemActor(item));
        refreshItems(shelf.items, null);
        this.texture = assets.texture(Images.PRELOAD__SHELF);

        shelf.onItemsChange(this, refreshItems);
    }

    function refreshItems(newDraw:List<SorcererItem>, previousDraw:Null<List<SorcererItem>>) {
        this.items = newDraw.map(item -> getItemActor(item));
        var padding = Data.placements.get(ShelfPadding).sure().x;
		for (i => actor in this.items) {
			actor.transition(Easing.QUAD_EASE_IN_OUT, 0.15, props -> {
				props.x = padding + (actor.texture.width + padding) * i;
				props.y = this.texture.height / 2;
			});
		}
	}
}
