package ld46.components;

import ld46.TournamentScreen.ItemActorFactory;
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
	private var hb:Text;

	public function new(assets:Assets, sorcerer:Sorcerer, ItemActorFactory:ItemActorFactory) {
		super();
		this.sorcerer = sorcerer;
		this.assets = assets;
		this.items = new Array<SorcererItemActor>();
		this.hb = new Text();

		this.texture = assets.texture(Images.PRELOAD__DUMMY);

		this.anchor(0.5, 0.96);
		this.size(50, 160);
		this.scale(0.9 + Math.random() * 0.2, 0.9 + Math.random() * 0.2);

		this.hb.pos(0, -this.height / 2 - 20);
		this.add(hb);

		for (item in sorcerer.items) {
			var itemActor = ItemActorFactory.getItemActor(item);
			items.push(itemActor);
			this.add(itemActor);
			switch (itemActor.item.itemData.slot) {
				case Chest:
					itemActor.pos(this.width * 0.5, this.height * 0.4);
				case Top:
					itemActor.pos(this.width * 0.5, 0 - itemActor.height * 0.30);
				case Hand:
					itemActor.pos(0 - itemActor.width * 0.3, this.height * 0.3);
			}
		}

		autorun(() -> {
			hb.content = Std.string(sorcerer.health) + ' / ' + sorcerer.calculatedStats.get(Data.StatsKind.Health.toString());
		});
	}
}
