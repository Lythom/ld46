package ld46.model;

import lythom.stuffme.AttributeValues;
import Data.StatsKind;

class Sorcerer extends tracker.Model {
	public var attributeSet:AttributeValues;
	public var items(get, never):Array<SorcererItem>;
    public var x:Float = 0;
    public var y:Float = 0;
    
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
	}

	public function get_items() {
		return [top, chest, hand];
	}

	public function equipItem(newItem:SorcererItem):SorcererItem {
		switch (newItem.itemData.slot) {
			case Chest:
				var prev = chest;
				chest = newItem;
				return prev;
			case Top:
				var prev = top;
				top = newItem;
				return prev;
			case Hand:
				var prev = hand;
				hand = newItem;
				return prev;
		}
    }
}
