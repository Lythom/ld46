package ld46.model;

import lythom.stuffme.Item;
import lythom.stuffme.AttributeValues;
import Data.StatsKind;

@:nullSafety(Off)
class Chaleace extends BoardEntity {
	@observe public var lockIn:Float = 0;

	public function new() {
		super();
	
		health = Data.configs.get(ChaleaceHealth).sure().value;
		role = Chaleace;

		attributeSet = new AttributeValues();
		attributeSet.setValue(Defense, Data.stats.get(Defense).sure().value);
		attributeSet.setValue(Health, Data.configs.get(ChaleaceHealth).sure().value);

		autorun(() -> {
			var itemList:Array<Item> = [buffs];
			calculatedStats = attributeSet.with(itemList).values;
		});
	}

	override public function isTargetable() {
		return lockIn > 0;
	}
}
