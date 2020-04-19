package ld46.model;

import lythom.stuffme.StuffMe;
import lythom.stuffme.AttributeValues;
import Data.StatsKind;

@:nullSafety(Off)
class Sorcerer extends tracker.Model {
	private var attributeSet:AttributeValues;

	@observe public var calculatedStats:AttributeValues;
	@observe public var items(get, null):Array<SorcererItem>;
	@observe public var x:Float = 0;
	@observe public var y:Float = 0;
	@observe public var health:Float = 0;
	@observe public var fighting:Bool = false;

	// configuration origin is the center of the player half field
	// positive value down and right
	// relates to positions while being bot-side. positions are mirrored if playing topside.
	@observe public var boardConfiguredX:Float = 0;
	@observe public var boardConfiguredY:Float = 0;

	private var top:SorcererItem;
	private var chest:SorcererItem;
	private var hand:SorcererItem;

	public function new() {
		super();
		attributeSet = new AttributeValues();
		attributeSet.set(AttackDamage.toString(), Data.stats.get(AttackDamage).sure().value);
		attributeSet.set(AttackRange.toString(), Data.stats.get(AttackRange).sure().value);
		attributeSet.set(AttackSpeed.toString(), Data.stats.get(AttackSpeed).sure().value);
		attributeSet.set(Defense.toString(), Data.stats.get(Defense).sure().value);
		attributeSet.set(Health.toString(), Data.stats.get(Health).sure().value);
		attributeSet.set(Power.toString(), Data.stats.get(Power).sure().value);
		top = new SorcererItem(Data.items.get(StarterTop).sure());
		chest = new SorcererItem(Data.items.get(StarterChest).sure());
		hand = new SorcererItem(Data.items.get(StarterHand).sure());

		autorun(() -> {
			calculatedStats = attributeSet.with([for (i in items) i]).values;
		});

		health = calculatedStats.get(Health.toString());
	}

	public function get_items() {
		return [top, chest, hand];
	}

	public function equipItem(newItem:SorcererItem):SorcererItem {
		switch (newItem.itemData.slot) {
			case Chest:
				var prev = chest;
				chest = newItem;
				this.invalidateItems();
				return prev;
			case Top:
				var prev = top;
				top = newItem;
				this.invalidateItems();
				return prev;
			case Hand:
				var prev = hand;
				hand = newItem;
				this.invalidateItems();
				return prev;
		}
	}
}
