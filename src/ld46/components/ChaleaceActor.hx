package ld46.components;

import ceramic.Fonts;
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

	public var description:Description;


	public function new(assets:Assets, chaleace:Chaleace, opponent:Bool = false) {
		super();
		this.chaleace = chaleace;
		this.assets = assets;
		this.healthText = new Text();
		this.healthBar = new BarActor(Data.colors.get(healthBG).sure().color, Data.colors.get(opponent ? opponentHealthFG : healthFG).sure().color);
		this.lockCooldown = new BarActor(Data.colors.get(lockBG).sure().color, Data.colors.get(lockFG).sure().color);
		this.description = new Description(getDescription());
		description.active = false;

		this.texture = assets.texture(Images.PRELOAD__CHALEACE);

		this.anchor(0.5, 0.96);
		this.size(75, 125);

		healthText.pos(20, -20);
		healthText.font = assets.font(Fonts.SIMPLY_MONO_60);
		healthText.pointSize = 15;
		add(healthText);

		healthBar.pos(0, -25);
		healthBar.size(width, 25);
		add(healthBar);
		healthBar.refresh();
		
		lockCooldown.pos(0, -50);
		lockCooldown.size(width, 25);
		lockCooldown.depth = 2;
		lockCooldown.whiteMargin = 0;
		lockCooldown.blackMargin = 3;
		add(lockCooldown);
		lockCooldown.refresh();

		var p = new ceramic.Point();

		this.onPointerOver(this, evt -> {
			if (evt.buttonId > -1)
				return;
			description.text.content = getDescription();
			description.text.computeContent();
			description.descHeight = Std.int(description.text.height + 40);
			description.descWidth = 320;
			this.visualToScreen(description.descWidth + this.width + 20, description.descHeight - 100, p);
			description.pos(p.x, p.y);
			description.active = true;
			description.depth = 9999;
			description.alpha = 0.75;
			description.refresh();
		});
		this.onPointerOut(this, evt -> {
			description.active = false;
		});
		this.onPointerDown(this, evt -> {
			description.active = false;
		});

		autorun(() -> {
			healthBar.value = chaleace.health / chaleace.calculatedStats.getValue(Health);
			lockCooldown.value = chaleace.lockIn / Data.configs.get(ChaleaceLockTimeInSec).sure().value;
			healthText.content = '' + Std.int(chaleace.health);
			healthBar.refresh();
			lockCooldown.refresh();
		});
	}

	public function updateDepth(value:Float) {
		this.depth = value;
		healthBar.depth = this.depth + 0.2;
		lockCooldown.depth = this.depth + 0.2;
		healthText.depth = healthBar.depth + 1;
	}

	public function getDescription():String {
		return Data.roles.get(Chaleace).sure().description;
	}
}
