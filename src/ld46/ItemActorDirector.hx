package ld46;

import ceramic.Visual;
import ceramic.Point;
import ceramic.Easing;
import ld46.model.SorcererItem;
import ld46.components.SorcererItemActor;
import haxe.ds.StringMap;
import ceramic.Assets;
import ceramic.Shortcuts.*;

class ItemActorDirector extends Visual {
	var items:StringMap<SorcererItemActor>;
	var assets:Assets;

	public function new(assets:Assets) {
		super();
		items = new StringMap<SorcererItemActor>();
		this.assets = assets;
		this.depthRange = -1;
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

	public function giveBack(itemActor:SorcererItemActor, prevParent:Visual = null) {
		if (itemActor == null)
			return;

		if (prevParent != null && prevParent == itemActor.parent) {
			itemActor.changeParent(null);
		}
		itemActor.depth = 89999;
		app.batchOnPostUpdate(itemActor.disappear);
	}

	public function mergeTransitionTo(itemActor:SorcererItemActor, to:Point) {
		itemActor.changeParent(this);
		itemActor.depth = 89999;
		return itemActor.transition(Easing.QUAD_EASE_OUT, 0.4, props -> {
			props.pos(to.x, to.y);
		});
	}

	private function createActor(item:SorcererItem) {
		if (item == null)
			throw "item is required";
		var itemActor = new SorcererItemActor(this.assets, item);
		itemActor.pos(2000, 650);
		items.set(item.id, itemActor);

		item.onMergeInto(this, otherItem -> {
			var otherActor = getItemActor(otherItem);
			var to = new Point();
			otherActor.visualToScreen(itemActor.width * itemActor.anchorX, itemActor.height * itemActor.anchorY, to);
			mergeTransitionTo(itemActor, to).sure().onComplete(this, () -> {
				itemActor.outTransition = Cut;
				giveBack(itemActor, this);
			});
		});

		return itemActor;
	}
}
