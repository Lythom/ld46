package ld46;

import ld46.model.SorcererItem;
import ld46.components.SorcererItemActor;
import haxe.ds.StringMap;
import ld46.components.ShopActor;
import ld46.components.TrashActor;
import ld46.components.ChaleaceActor;
import ld46.components.SorcererActor;
import ld46.components.Board;
import ld46.components.NextRoundButton;
import ld46.components.ShelfActor;
import ld46.model.Player;
import ld46.model.SorcererTournament;
import ceramic.KeyCode;
import ceramic.Key;
import ceramic.Path;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;
import ceramic.Text;
import ceramic.Visual;
import ceramic.Shortcuts.*;

@:nullSafety(Off)
class TournamentScreen extends Visual {
	var assets:Assets;
	var localPlayer:Player;
	var allPlayers:Player;

	var shop:ShopActor;
	var shelf:ShelfActor;
	var nextRoundButton:NextRoundButton;
	var mainBoard:Board;
	var opponentBoard:Board;
	var sorcerers:Array<SorcererActor>;
	var chaleace:ChaleaceActor;
	var trash:TrashActor;
	var playersScores:Text;
	var items:StringMap<SorcererItemActor>;

	public function new(assets:Assets, localPlayer:Player, allPlayers:Array<Player>) {
		super();
		this.assets = assets;
		this.localPlayer = localPlayer;
		this.allPlayers = localPlayer;

		nextRoundButton = new NextRoundButton(assets);
		mainBoard = new Board(assets.texture(Images.PRELOAD__MAIN_BOARD));
		opponentBoard = new Board(assets.texture(Images.PRELOAD__MAIN_BOARD));
		sorcerers = new Array<SorcererActor>();
		for (s in localPlayer.sorcerers) {
			sorcerers.push(new SorcererActor(assets, s));
		}
		chaleace = new ChaleaceActor(assets, localPlayer.chaleace);
		trash = new TrashActor(assets);
		playersScores = new Text();
		items = new StringMap<SorcererItemActor>();
		shop = new ShopActor(assets, localPlayer.shop, getItemActor.sure());
		shelf = new ShelfActor(assets, localPlayer.shelf, getItemActor.sure());


		shop.onPurchaseItem(this, item -> {
			var bought = localPlayer.shop.buy(item);
			if (bought) {
				localPlayer.shelf.put(item);
			}
		});

		app.onKeyDown(this, e -> {
			if (e.keyCode == KeyCode.ESCAPE) {
				this.destroy();
				new MainMenu(assets);
			}
		});
		HotLoader.instance.onReload(this, loadContent);

		loadContent();

		// var tournament = new SorcererTournament();
	}

	function getItemActor(item:SorcererItem):SorcererItemActor {
		if (items.exists(item.id))
			return items.get(item.id).sure();
		var itemActor = new SorcererItemActor(this.assets, item);
		items.set(item.id, itemActor);
		return itemActor;
	}

	function loadContent() {
		shop.x = Data.placements.get(Shop).sure().x;
		shop.y = Data.placements.get(Shop).sure().y;
		shelf.x = Data.placements.get(Shelf).sure().x;
		shelf.y = Data.placements.get(Shelf).sure().y;
	}

	function update(delta:Float) {}
}
