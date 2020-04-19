package ld46.model;

import lythom.stuffme.AttributeValues;
import Data.StatsKind;

@:nullSafety(Off)
class Chaleace extends tracker.Model {
	@observe public var attributeSet:AttributeValues;
	@observe public var x:Float = 0;
	@observe public var y:Float = 0;
	@observe public var health:Int = 100;

	public function new() {
		super();
		x = 0;
		y = 0;
		health = 100;

		attributeSet = new AttributeValues();
		attributeSet.set(Defense.toString(), Data.stats.get(Defense).sure().value);
		attributeSet.set(Health.toString(), Data.configs.get(ChaleaceHealth).sure().value);
	}
}
