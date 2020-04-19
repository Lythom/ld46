package ld46;

import ceramic.Easing;
import ceramic.Entity;
import ld46.model.SorcererItem;
import ld46.components.SorcererItemActor;
import haxe.ds.StringMap;
import ceramic.Assets;

class ItemActorDirector extends Entity {
	var items:StringMap<SorcererItemActor>;
	var assets:Assets;

	public function new(assets:Assets) {
        super();
		items = new StringMap<SorcererItemActor>();
		this.assets = assets;
	}

	public function getItemActor(item:SorcererItem):SorcererItemActor {
		if (items.exists(item.id))
			return items.get(item.id).sure();
		var itemActor = new SorcererItemActor(this.assets, item);
		items.set(item.id, itemActor);

		item.onceMergeInto(this, otherItem -> {
			var otherActor = getItemActor(otherItem);
			itemActor.transition(Easing.QUAD_EASE_OUT, 0.25, props -> {
				props.pos(otherActor.x, otherActor.y);
			}).onceComplete(this, () -> {
				itemActor.destroy();
			});
		});
		return itemActor;
	}
}