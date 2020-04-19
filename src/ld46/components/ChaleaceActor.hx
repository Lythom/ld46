package ld46.components;

import ceramic.Text;
import ld46.model.Chaleace;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;

class ChaleaceActor extends Quad {
	public var chaleace:Chaleace;

	private var assets:Assets;
	private var hb:Text;

	public function new(assets:Assets, chaleace:Chaleace) {
		super();
		this.chaleace = chaleace;
		this.assets = assets;
		this.hb = new Text();

		this.texture = assets.texture(Images.PRELOAD__CHALEACE);

		this.anchor(0.5, 0.96);
		this.size(75, 125);

		this.hb.pos(0, -this.height / 2 - 20);
		this.add(hb);

		autorun(() -> {
			hb.content = Std.string(chaleace.health) + ' / ' + chaleace.calculatedStats.get(Data.StatsKind.Health.toString());
		});
	}
}
