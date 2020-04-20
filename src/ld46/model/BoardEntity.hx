package ld46.model;

import lythom.stuffme.Item;
import lythom.stuffme.AttributeValues;


@:nullSafety(Off)
class BoardEntity extends tracker.Model {
	private var attributeSet:AttributeValues;

	@observe public var calculatedStats:AttributeValues;
	@observe public var buffs:Item;
	@observe public var x:Float = 0;
	@observe public var y:Float = 0;
	@observe public var health:Float = 0;
	@observe public var fighting:Bool = false;
	@observe public var role:Data.RolesKind;

	// configuration origin is the center of the player half field
	// positive value down and right
	// relates to positions while being bot-side. positions are mirrored if playing topside.
	@observe public var boardConfiguredX:Float = 0;
	@observe public var boardConfiguredY:Float = 0;

	@event function damaged(from:BoardEntity, calculatedDamageTaken:Float):Void;

	public function new() {
		super();
		buffs = new Item(null, [], null);
		attributeSet = new AttributeValues();
	}

	public function isTargetable() {
		return health > 0;
	}

	public function takeDamage(from:BoardEntity, calculatedDamage:Float) {
		health = Math.max(health - calculatedDamage, 0);
		if (health > 0) {
			this.emitDamaged(from, calculatedDamage);
		}
	}

	public function boardConfigured(x:Float, y:Float) {
		boardConfiguredX = x;
		boardConfiguredY = y;
	}

	public function moveToPlayerB() {
		x = -x;
		y = -y;
		x += 398;
		y -= 168;
	}
}
