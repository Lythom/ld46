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
	private var healthText:Text;
	private var healthBar:BarActor;

	public function new(assets:Assets, sorcerer:Sorcerer, itemActorDirector:ItemActorDirector, opponent:Bool = false) {
		super();
		this.sorcerer = sorcerer;
		this.assets = assets;
		this.itemActorDirector = itemActorDirector;
		this.items = new Array<SorcererItemActor>();
		this.healthText = new Text();
		this.healthBar = new BarActor(Data.colors.get(healthBG).sure().color, Data.colors.get(opponent ? opponentHealthFG : healthFG).sure().color);

		this.texture = assets.texture(Images.PRELOAD__DUMMY);

		this.anchor(0.5, 0.96);
		this.size(50, 160);
		this.scale(0.9 + Math.random() * 0.2, 0.9 + Math.random() * 0.2);

		healthText.pos(0, -50);
		add(healthText);

		healthBar.pos(0, -50);
		healthBar.size(250, 50);
		healthBar.depth = 2;
		add(healthBar);

		sorcerer.onItemsChange(this, (_, __) -> {
			refreshItems();
		});
		refreshItems();

		autorun(() -> {
			healthBar.value = sorcerer.health / sorcerer.calculatedStats.getValue(Health);
			healthText.content = Std.int(sorcerer.health) + ' / ' + sorcerer.calculatedStats.getValue(Health);
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
