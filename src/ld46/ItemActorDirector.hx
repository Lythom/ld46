package ld46;

import ceramic.Point;
import ceramic.Color;
import ceramic.Easing;
import ceramic.Entity;
import ld46.model.SorcererItem;
import ld46.components.SorcererItemActor;
import haxe.ds.StringMap;
import ceramic.Assets;
import ceramic.Shortcuts.*;

class ItemActorDirector extends Entity {
	var items:StringMap<SorcererItemActor>;
	var assets:Assets;

	public function new(assets:Assets) {
		super();
		items = new StringMap<SorcererItemActor>();
		this.assets = assets;
	}

	public function getItemActor(item:SorcererItem):SorcererItemActor {
		if (items.exists(item.id)) {
			var itemActor = items.get(item.id).sure();
			if (itemActor.destroyed) {
				return createActor(item);
			}
			itemActor.active = true;
			return itemActor;
		}
		return createActor(item);
	}

	public function giveBack(itemActor:SorcererItemActor) {
		if (itemActor.parent != null)
			itemActor.parent.remove(itemActor);
		itemActor.active = false;
	}

	private function createActor(item:SorcererItem) {
		if (item == null)
			throw "item is required";
		var itemActor = new SorcererItemActor(this.assets, item);
		itemActor.pos(2000, 650);
		// itemActor.color = Color.fromHSLuv(Math.random() * 360, 0.3 + Math.random() * 0.3, 0.5);
		items.set(item.id, itemActor);

		item.onceMergeInto(this, otherItem -> {
			// post update to not get overriden by shop to shelf transition
			app.oncePostUpdate(this, delta -> {
				var otherActor = getItemActor(otherItem);
				var from = new Point();
				itemActor.visualToScreen(0, 0, from);
				var to = new Point();
				otherActor.visualToScreen(itemActor.width * itemActor.anchorX, itemActor.height * itemActor.anchorY, to);
				if (itemActor.parent != null)
					itemActor.parent.remove(itemActor);
				itemActor.pos(from.x + itemActor.width * itemActor.anchorX, from.y + itemActor.height * itemActor.anchorY);
				itemActor.depth = 9999;
				var tween = itemActor.transition(Easing.QUAD_EASE_OUT, 0.45, props -> {
					props.pos(to.x, to.y);
				});
				if (tween == null) {
					giveBack(itemActor);
				} else {
					tween.onceComplete(this, () -> {
						giveBack(itemActor);
					});
				}
			});
		});

		return itemActor;
	}
}
