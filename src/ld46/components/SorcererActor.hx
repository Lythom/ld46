package ld46.components;

import ceramic.Fonts;
import lythom.stuffme.AttributeValues;
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

	public var description:Description;

	public function new(assets:Assets, sorcerer:Sorcerer, itemActorDirector:ItemActorDirector, opponent:Bool = false) {
		super();
		this.sorcerer = sorcerer;
		this.assets = assets;
		this.itemActorDirector = itemActorDirector;
		this.items = new Array<SorcererItemActor>();
		this.healthText = new Text();
		this.healthBar = new BarActor(Data.colors.get(healthBG).sure().color, Data.colors.get(opponent ? opponentHealthFG : healthFG).sure().color);
		this.description = new Description(getDescription());
		description.active = false;

		this.texture = assets.texture(Images.PRELOAD__DUMMY);

		this.anchor(0.5, 0.96);
		this.size(50, 160);
		this.scale(0.9 + Math.random() * 0.2, 0.9 + Math.random() * 0.2);

		healthText.pos(20, -20);
		healthText.font = assets.font(Fonts.SIMPLY_MONO_60);
		healthText.pointSize = 15;
		add(healthText);

		healthBar.pos(0, -25);
		healthBar.size(width, 25);
		add(healthBar);
		healthBar.refresh();

		sorcerer.onItemsChange(this, (_, __) -> {
			refreshItems();
		});
		refreshItems();

		sorcerer.offAttackTarget();
		sorcerer.onAttackTarget(this, (from, target, damage) -> {
			var travelX = target.x - from.x;
			var travelY = target.y - from.y;
			var startX = this.width * 0.5;
			var startY = this.height * 0.5;
			add(new ld46.fx.AttackFX(startX, startY, startX + travelX, startY + travelY, damage));
		});

		var p = new Point();

		this.onPointerOver(this, evt -> {
			if (evt.buttonId > -1)
				return;
			description.text.content = getDescription();
			description.text.computeContent();
			description.descHeight = Std.int(description.text.height + 40);
			description.descWidth = 320;
			this.visualToScreen(description.descWidth + this.width + 20, description.descHeight - 100, p);
			description.pos(p.x, p.y);
			description.active = true;
			description.depth = 9999;
			description.alpha = 0.75;
			description.refresh();
		});
		this.onPointerOut(this, evt -> {
			description.active = false;
		});
		this.onPointerDown(this, evt -> {
			description.active = false;
		});

		autorun(() -> {
			healthBar.value = sorcerer.health / sorcerer.calculatedStats.getValue(Health);
			healthText.content = '' + Std.int(sorcerer.health);

			healthBar.width = this.width;
			healthBar.refresh();
			this.active = sorcerer.health > 0;
		});
	}

	public function updateDepth(value:Float) {
		this.depth = value;
		for (actor in items) {
			actor.depth = this.depth + 0.1;
		}
		healthBar.depth = this.depth + 0.2;
		healthText.depth = healthBar.depth + 1;
	}

	public function getDescription():String {
		var items = sorcerer.items;
		return sorcerer.calculatedStats.getAttributeDescription() + '\n ---- \n' + items.map(SorcererItemActor.getDescription).join('\n ---- \n');
	}

	public function refreshItems() {
		items = [];
		for (item in sorcerer.items) {
			var itemActor = itemActorDirector.getItemActor(item);
			items.push(itemActor);
			this.add(itemActor);
			switch (itemActor.item.itemData.slot) {
				case Chest:
					itemActor.pos(this.width * 0.5, this.height * 0.45);
				case Top:
					itemActor.pos(this.width * 0.5, 0 - itemActor.height * 0.29);
				case Hand:
					itemActor.pos(0 - itemActor.width * 0.3, this.height * 0.3);
			}
			wireItem(itemActor);
		}
	}

	public function wireItem(itemActor:SorcererItemActor) {
		itemActor.offPointerDown();
		itemActor.offPointerOver();
		itemActor.offPointerOut();
		itemActor.hideDescription();
		itemActor.scale(1, 1);

		// itemActor.onPointerOver(this, evy -> {
		// 	itemActor.transition(Easing.QUAD_EASE_OUT, 0.15, props -> {
		// 		props.scaleX = 1.1;
		// 		props.scaleY = 1.1;
		// 	});
		// 	itemActor.showDescription();
		// });

		// itemActor.onPointerOut(this, evt -> {
		// 	itemActor.transition(Easing.QUAD_EASE_IN_OUT, 0.15, props -> {
		// 		props.scaleX = 1;
		// 		props.scaleY = 1;
		// 	});
		// 	itemActor.hideDescription();
		// });
	}

	public function getItemOnSlot(slot:Data.Items_slot):Null<SorcererItemActor> {
		return this.items.find(i -> i.item.itemData.slot == slot);
	}
}
