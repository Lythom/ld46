package ld46.model;

import tracker.Observable;
import tracker.Events;
import lythom.stuffme.Bonus;
import lythom.stuffme.Item;

@:nullSafety(Off)
class SorcererItem extends Item implements Events implements Observable {
	public static function createBonus(definition:Data.Items_provideBonus):Bonus {
		var statName = definition.stat.id.toString();
		return new Bonus(args -> {
			var level = cast(args.item, SorcererItem).level;
			return [
				statName => args.values.get(statName).or(0) * definition.percentValue * level + definition.flatValue * level
			];
		}, args -> {
			var level = cast(args.item, SorcererItem).level;
			var percentValue = definition.percentValue * level;
			var flatValue = definition.flatValue * level;
			return '${statName}: ${flatValue == 0 ? '' : Std.string(Std.int(flatValue))}${percentValue == 0 ? '' : '+' + Std.string(Std.int(percentValue * 100)) + ' %'}';
		});
	}

	@observe public var level:Int = 1;
	public var itemData:Data.Items;

	@event function mergeInto(item:SorcererItem):Void;

	public function new(itemData:Data.Items) {
		this.itemData = itemData;
		var bonuses = itemData.provideBonus.map(SorcererItem.createBonus);
		super(null, bonuses, null);
	}

	public function triggerMergeInto(item:SorcererItem) {
		this.emitMergeInto(item);
	}
}
