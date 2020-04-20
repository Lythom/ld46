package ld46.components;

import ceramic.Text;
import ld46.model.Chaleace;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;

class ChaleaceActor extends Quad {
	public var chaleace:Chaleace;

	private var assets:Assets;
	private var healthText:Text;
	private var healthBar:BarActor;
	private var lockCooldown:BarActor;

	public function new(assets:Assets, chaleace:Chaleace, opponent:Bool = false) {
		super();
		this.chaleace = chaleace;
		this.assets = assets;
		this.healthText = new Text();
		this.healthBar = new BarActor(Data.colors.get(healthBG).sure().color, Data.colors.get(opponent ? opponentHealthFG : healthFG).sure().color);
		this.lockCooldown = new BarActor(Data.colors.get(lockBG).sure().color, Data.colors.get(lockFG).sure().color);

		this.texture = assets.texture(Images.PRELOAD__CHALEACE);

		this.anchor(0.5, 0.96);
		this.size(75, 125);

		healthText.pos(0, -25);
		healthText.pointSize = 10;
		add(healthText);

		healthBar.pos(0, -25);
		healthBar.size(width, 25);
		healthBar.depth = 2;
		add(healthBar);
		healthBar.refresh();
		
		lockCooldown.pos(0, -50);
		lockCooldown.size(width, 25);
		lockCooldown.depth = 2;
		lockCooldown.whiteMargin = 0;
		lockCooldown.blackMargin = 3;
		add(lockCooldown);
		lockCooldown.refresh();

		autorun(() -> {
			healthBar.value = chaleace.health / chaleace.calculatedStats.getValue(Health);
			lockCooldown.value = chaleace.lockIn / Data.configs.get(ChaleaceLockTimeInSec).sure().value;
			healthText.content = Std.int(chaleace.health) + ' / ' + chaleace.calculatedStats.getValue(Health);
			healthBar.refresh();
			lockCooldown.refresh();
		});
	}
}
