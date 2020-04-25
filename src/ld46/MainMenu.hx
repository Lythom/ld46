package ld46;

import ceramic.Easing;
import ceramic.Fonts;
import ceramic.KeyCode;
import ld46.components.BarActor;
import ld46.model.SorcererTournament;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;
import ceramic.Text;
import ceramic.Visual;
import ceramic.Shortcuts.*;

@:nullSafety(Strict)
class MainMenu extends Visual {

	var bg:Quad;
	var test:Quad;

	var assets:Assets;

	public function new(assets:Assets) {
		super();
		this.assets = assets;

		test = new Quad();
		bg = new Quad();


		test.onPointerDown(this, evt -> {
			this.destroy();
			var tournament = new SorcererTournament();
			var allPlayer = tournament.getPlayers();
			var player = allPlayer[0];
			new TournamentScreen(assets, player, allPlayer, tournament);
		});
		test.onPointerOver(this, evt -> {
			test.transition(Easing.QUAD_EASE_OUT, 0.25, props -> {
				props.scale(1.1, 1.1);
			});
		});
		test.onPointerOut(this, evt -> {
			test.transition(Easing.QUAD_EASE_OUT, 0.25, props -> {
				props.scale(1, 1);
			});
		});
		test.depth = 2;
		test.pos(screen.width * 0.5, screen.height * 0.5);
		test.anchor(0.5, 0.5);
		
		this.add(bg);
		this.add(test);


		app.onKeyDown(this, key -> {
			if (key.keyCode == KeyCode.KP_PLUS) {
				trace(assets.font(Fonts.SIMPLY_MONO_60));
				new ld46.fx.AnnounceFX('FIGHT', assets.font(Fonts.SIMPLY_MONO_60));
			}
		});

		HotLoader.instance.onReload(this, loadContent);
		loadContent();
	}

	function loadContent() {
		test.texture = assets.texture(Images.PRELOAD__PLAY);
		bg.texture = assets.texture(Images.PRELOAD__KEYART);
	}

	function update(delta:Float) {}
}
