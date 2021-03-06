package;

import ceramic.Fonts;
import ceramic.Text;
import ceramic.Texts;
import ceramic.Assets;
import ceramic.Color;
import ceramic.InitSettings;
import ceramic.Entity;
import ceramic.Shortcuts.*;

using NullTools;

// TODO: abstract type for stats String to Statkind conversion

class Project extends Entity {
	var assets:Assets;

	function new(settings:InitSettings) {
		super();

		if (settings != null) {
			settings.antialiasing = 4;
			settings.background = Color.GRAY;
			settings.targetWidth = 1280;
			settings.targetHeight = 720;
			settings.scaling = FILL;

			assets = new Assets();

			app.onceReady(this, ready);
		}
	}

	function ready() {
		assets.addFont(Fonts.SIMPLY_MONO_60);
		#if debug
		assets.watchDirectory(ceramic.macros.DefinesMacro.getDefine('assets_path'));
		#end
		assets.addAll(~/^preload\//);
		assets.add(Texts.CDB);
		assets.onceComplete(this, start);
		assets.load();
	}

	function start(success:Bool) {
		new HotLoader(() -> {
			var castleDBContent = assets.text(Texts.CDB);
			Data.load(castleDBContent);
		});
		new ld46.MainMenu(assets);
	}
}
