package ld46.model;

import lythom.stuffme.AttributeValues;
import Data.StatsKind;

@:nullSafety(Off)
class Chaleace extends tracker.Model {
	private var attributeSet:AttributeValues;
	@observe public var calculatedStats:AttributeValues;
	@observe public var x:Float = 0;
	@observe public var y:Float = 0;
	@observe public var health:Int = 100;
	@observe public var fighting:Bool = false;
	
	// configuration origin is the center of the player half field
	// positive value down and right
	// relates to positions while being bot-side. positions are mirrored if playing topside.
	@observe public var boardConfiguredX:Float = 0;
	@observe public var boardConfiguredY:Float = 0;

	public function new() {
		super();
		x = 0;
		y = 0;
		health = Data.configs.get(ChaleaceHealth).sure().value;

		attributeSet = new AttributeValues();
		attributeSet.set(Defense.toString(), Data.stats.get(Defense).sure().value);
		attributeSet.set(Health.toString(), Data.configs.get(ChaleaceHealth).sure().value);

		autorun(() -> {
			calculatedStats = attributeSet.with([]).values;
		});
	}
}
