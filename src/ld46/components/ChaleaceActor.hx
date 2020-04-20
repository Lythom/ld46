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
	private var healthBar:BarActor;
	private var lockCooldown:BarActor;

	public function new(assets:Assets, chaleace:Chaleace, opponent:Bool = false) {
		super();
		this.chaleace = chaleace;
		this.assets = assets;
		this.hb = new Text();
		this.healthBar = new BarActor(Data.colors.get(healthBG).sure().color, Data.colors.get(opponent ? opponentHealthFG : healthFG).sure().color);
		this.lockCooldown = new BarActor(Data.colors.get(lockBG).sure().color, Data.colors.get(lockFG).sure().color);

		this.texture = assets.texture(Images.PRELOAD__CHALEACE);

		this.anchor(0.5, 0.96);
		this.size(75, 125);

		hb.pos(0, 0);
		add(hb);

		healthBar.pos(0, 0);
		healthBar.size(250, 50);
		healthBar.depth = 2;
		add(healthBar);
		
		lockCooldown.pos(0, -50);
		lockCooldown.size(width, 50);
		lockCooldown.depth = 2;
		add(lockCooldown);

		autorun(() -> {
			healthBar.value = chaleace.health / chaleace.calculatedStats.getValue(Health);
			lockCooldown.value = chaleace.lockIn / Data.configs.get(ChaleaceLockTimeInSec).sure().value;
			hb.content = Std.int(chaleace.health) + ' / ' + chaleace.calculatedStats.getValue(Health);
		});
	}
}
