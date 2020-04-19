package ld46.model;

import lythom.stuffme.Bonus;
import lythom.stuffme.Item;

class SorcererItem extends Item {
	public static function createBonus(definition:Data.Items_provideBonus):Bonus {
		return new Bonus(args -> {
            var statName = definition.stat.id.toString();
            return [statName => args.values.get(statName).or(0) * definition.percentValue + definition.flatValue];
		});
    }
    
    public var itemData:Data.Items;

	public function new(itemData:Data.Items) {
        this.itemData = itemData;
		var bonuses = itemData.provideBonus.map(SorcererItem.createBonus);
		super(null, bonuses, null);
	}
}
