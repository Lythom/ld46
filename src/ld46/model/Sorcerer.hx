package ld46.model;

import lythom.stuffme.AttributeValues;
import ceramic.Timer;
import ceramic.Point;
import lythom.stuffme.Item;
import Data.StatsKind;

@:nullSafety(Off)
class Sorcerer extends BoardEntity {
	@observe public var items(get, null):Array<SorcererItem>;

	private var top:SorcererItem;
	private var chest:SorcererItem;
	private var hand:SorcererItem;

	public var target:Null<BoardEntity>;

	public var attackCooldown:Float = 0;

	@event function attackTarget(from:BoardEntity, target:BoardEntity, attack:Float):Void;

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
			var itemList:Array<Item> = [for (i in items) i];
			itemList.push(buffs);
			calculatedStats = attributeSet.with(itemList).values;
			role = top.itemData.provideRole == null ? Duelist : top.itemData.provideRole.id;
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

	public function moveAttack(delta:Float) {
		if (target != null) {
			var dist = this.distanceWith(target);
			if (dist > calculatedStats.getValue(AttackRange)) {
				// in pxPerSeconds
				var moveSpeed = Data.configs.get(MoveSpeed).sure().value;
				var moveRange = moveSpeed * delta;
				var angle = LD46Utils.angleInRad(x, y, target.x, target.y);

				// TODO dodge manoeuvres to avoid collisions with other entities and allow blocking strategies

				x = x + Math.cos(angle) * moveRange;
				y = y + Math.sin(angle) * moveRange;
			} else {
				if (attackCooldown <= 0) {
					var attack = this.calculatedStats.getValue(AttackDamage);
					this.emitAttackTarget(this, target, attack);
					this.attackCooldown = 1 / this.calculatedStats.getValue(AttackSpeed, 0.001);
				}
			}
			attackCooldown -= delta;
		}
	}

	public function targetClosest(boardEntities:Array<BoardEntity>) {
		target = null;

		var role:Data.RolesKind = Duelist;
		if (top.itemData.provideRole != null) {
			role = top.itemData.provideRole.id;
		}
		// TODO: put this list in castleDB
		var targetPriorities:Array<Data.RolesKind>;
		switch (role) {
			case Duelist:
				targetPriorities = [Duelist, Saboteur, Protector, Chaleace];
			case Saboteur:
				targetPriorities = [Chaleace, Saboteur, Duelist, Protector];
			case Protector:
				targetPriorities = [Saboteur, Duelist, Protector, Chaleace];
			case Chaleace:
				targetPriorities = [];
		}
		for (priority in targetPriorities) {
			for (entity in boardEntities) {
				var bestDist:Float = 999;
				if (entity.role == priority && entity.isTargetable()) {
					var dist = this.distanceWith(entity);
					if (dist < bestDist) {
						target = entity;
						bestDist = dist;
					}
				}
				if (target != null)
					return;
			}
		}
	}
}
