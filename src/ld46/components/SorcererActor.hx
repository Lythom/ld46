package ld46.components;

import ceramic.Easing;
import ld46.ItemActorDirector;
import ceramic.Point;
import ceramic.Text;
import ceramic.Images;
import ceramic.Assets;
import ld46.model.Sorcerer;
import ceramic.Quad;
import ceramic.Shortcuts.*;

class SorcererActor extends Quad {
	public var sorcerer:Sorcerer;
	public var items:Array<SorcererItemActor>;

	private var assets:Assets;
	private var itemActorDirector:ItemActorDirector;
	private var hb:Text;

	public function new(assets:Assets, sorcerer:Sorcerer, itemActorDirector:ItemActorDirector, shelf:ShelfActor) {
		super();
		this.sorcerer = sorcerer;
		this.assets = assets;
		this.itemActorDirector = itemActorDirector;
		this.items = new Array<SorcererItemActor>();
		this.hb = new Text();

		this.texture = assets.texture(Images.PRELOAD__DUMMY);

		this.anchor(0.5, 0.96);
		this.size(50, 160);
		this.scale(0.9 + Math.random() * 0.2, 0.9 + Math.random() * 0.2);

		this.hb.pos(0, -this.height / 2 - 20);
		this.add(hb);

		sorcerer.onItemsChange(this, (_,__) -> {
			refreshItems();
		});
		refreshItems();

		autorun(() -> {
			hb.content = Std.string(sorcerer.health) + ' / ' + sorcerer.calculatedStats.get(Data.StatsKind.Health.toString());
		});
	}

	public function refreshItems() {
		trace('refreshItems');
		items = [];
		for (item in sorcerer.items) {
			var itemActor = itemActorDirector.getItemActor(item);
			items.push(itemActor);
			this.add(itemActor);
			switch (itemActor.item.itemData.slot) {
				case Chest:
					itemActor.pos(this.width * 0.5, this.height * 0.4);
				case Top:
					itemActor.pos(this.width * 0.5, 0 - itemActor.height * 0.30);
				case Hand:
					itemActor.pos(0 - itemActor.width * 0.3, this.height * 0.3);
			}
			wireItem(itemActor);
		}
	}

	public function wireItem(itemActor:SorcererItemActor) {
		itemActor.offPointerDown();
		itemActor.offPointerOver();
		itemActor.onPointerOver(this, evy -> {
			itemActor.transition(Easing.QUAD_EASE_OUT, 0.15, props -> {
				props.scaleX = 1.1;
				props.scaleY = 1.1;
			});
			itemActor.showDescription();
		});
		itemActor.offPointerOut();
		itemActor.onPointerOut(this, evt -> {
			itemActor.transition(Easing.QUAD_EASE_IN_OUT, 0.15, props -> {
				props.scaleX = 1;
				props.scaleY = 1;
			});
			itemActor.hideDescription();
		});
	}

	public function getItemOnSlot(slot:Data.Items_slot):Null<SorcererItemActor> {
		return this.items.find(i -> i.item.itemData.slot == slot);
	}
}
