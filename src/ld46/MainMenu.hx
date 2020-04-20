package ld46;

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
	var text:Text;
	var test:Quad;

	var assets:Assets;

	public function new(assets:Assets) {
		super();
		this.assets = assets;
		text = new Text();
		text.pos(screen.width / 2, 100);
		test = new Quad();
		test.onPointerDown(this, evt -> {
			this.destroy();
			var tournament = new SorcererTournament();
			var allPlayer = tournament.getPlayers();
			var player = allPlayer[0];
			new TournamentScreen(assets, player, allPlayer, tournament);
		});
		this.add(text);
		this.add(test);


		app.onKeyDown(this, key -> {
			if (key.keyCode == KeyCode.KP_PLUS) {
				trace(assets.font(Fonts.SIMPLY_MONO_60));
				new ld46.fx.AnnounceFX('FIGHT', assets.font(Fonts.SIMPLY_MONO_60));
			}
		});

		HotLoader.instance.onReload(this, loadContent);
		loadContent();

		// var tournament = new SorcererTournament();
	}

	function loadContent() {
		text.content = "Sorcerer Tournament";
		test.texture = assets.texture(Images.PRELOAD__NEXT_ROUND_BUTTON);
	}

	function update(delta:Float) {}
}
