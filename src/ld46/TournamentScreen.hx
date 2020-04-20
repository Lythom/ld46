package ld46;

import ceramic.Easing;
import ld46.components.ShopActor;
import ld46.components.TrashActor;
import ld46.components.Board;
import ld46.components.NextRoundButton;
import ld46.components.ShelfActor;
import ld46.model.Player;
import ld46.model.SorcererTournament;
import ceramic.Assets;
import ceramic.Text;
import ceramic.Visual;
import ceramic.Shortcuts.*;

@:nullSafety(Off)
class TournamentScreen extends Visual {
	var assets:Assets;
	var itemActorDirector:ItemActorDirector;

	public var localPlayer:Player;

	var allPlayers:Player;

	var shop:ShopActor;
	var shelf:ShelfActor;
	var nextRoundButton:NextRoundButton;
	var mainBoard:Board;
	var opponentBoard:Null<Board>;

	var trash:TrashActor;
	var playersScores:Text;

	public function new(assets:Assets, localPlayer:Player, allPlayers:Array<Player>, tournament:SorcererTournament) {
		super();
		this.assets = assets;
		this.localPlayer = localPlayer;
		this.allPlayers = localPlayer;

		this.itemActorDirector = new ItemActorDirector(assets);

		nextRoundButton = new NextRoundButton(assets);
		playersScores = new Text();

		shop = new ShopActor(assets, localPlayer.shop, itemActorDirector);
		shelf = new ShelfActor(assets, localPlayer.shelf, itemActorDirector);
		trash = new TrashActor(assets, shelf);
		mainBoard = new Board(assets, localPlayer, this.itemActorDirector, shelf);

		add(mainBoard);
		mainBoard.depth = 10;
		add(trash);
		trash.depth = 99;
		add(shop);
		shop.depth = 101;
		shop.anchor(0,0);
		add(shelf);
		shelf.depth = 102;
		shelf.anchor(0,0);
		add(playersScores);
		playersScores.depth = 99;
		add(nextRoundButton);
		nextRoundButton.depth = 99;

		trash.onThrowItem(this, item -> {
			shelf.shelf.remove(item);
			tournament.returnOneToDeck(item);
		});

		nextRoundButton.onPointerDown(this, evt -> {
			localPlayer.shop.drawItems(SorcererTournament.debugInstance);
		});

		shop.onPurchaseItem(this, item -> {
			if (!localPlayer.shop.canBuy())
				return;
			var hasRoom = localPlayer.shelf.put(item);
			if (hasRoom) {
				localPlayer.shop.processPurchase(item);
			} else {
				localPlayer.shelf.putOnHiddenTemporarySlot(item);
				// will trigger merge if any and free the hidden slot. Else, remove it from shelf.
				if (localPlayer.shelf.hasHiddenTempItem()) {
					trace("was on shelf but has not been merged: removed.");
					localPlayer.shelf.remove(item);
				}
			}
		});

		localPlayer.onGameStateChange(this, (_, __) -> updatePlacements());

		app.onKeyDown(this, e -> {
			if (e.keyCode == ceramic.KeyCode.ESCAPE) {
				this.destroy();
				new MainMenu(assets);
			}
			if (e.keyCode == ceramic.KeyCode.KP_PLUS) {
				localPlayer.shop.credits++;
			}
			if (e.keyCode == ceramic.KeyCode.KP_MULTIPLY) {
				localPlayer.shop.drawItems(SorcererTournament.debugInstance);
			}
		});
		HotLoader.instance.onReload(this, updatePlacements);

		updatePlacements();

		// var tournament = new SorcererTournament();
	}

	function updatePlacements() {
		if (localPlayer.gameState == ShopEquip) {
			if (opponentBoard != null)
				transitionDisable(opponentBoard, Data.placements.get(OpponentBoard).sure(), 1000, -500);
			transitionActivate(mainBoard, Data.placements.get(MainBoardShop).sure(), 0, 0);
			transitionActivate(shop, Data.placements.get(Shop).sure(), 1000, 0);
			transitionActivate(shelf, Data.placements.get(Shelf).sure(), 0, 500);
			transitionActivate(trash, Data.placements.get(Trash).sure(), -500, 0);
		} else {
			if (opponentBoard != null)
				transitionActivate(opponentBoard, Data.placements.get(OpponentBoard).sure(), -1000, 500);
			transitionDisable(mainBoard, Data.placements.get(MainBoardShop).sure(), 0, 0);
			transitionDisable(shop, Data.placements.get(Shop).sure(), -1000, 0);
			transitionDisable(shelf, Data.placements.get(Shelf).sure(), 0, -500);
			transitionDisable(trash, Data.placements.get(Trash).sure(), 500, 0);
		}
	}

	function transitionActivate(visual:Visual, placement:Data.Placements, fromOffsetX:Float, fromOffsetY:Float) {
		visual.active = true;
		visual.x = placement.x + fromOffsetX;
		visual.y = placement.y + fromOffsetY;
		visual.transition(Easing.QUAD_EASE_OUT, 0.3, props -> {
			props.x = placement.x;
			props.y = placement.y;
		});
	}

	function transitionDisable(visual:Visual, placement:Data.Placements, fromOffsetX:Float, fromOffsetY:Float) {
		visual.x = placement.x + fromOffsetX;
		visual.y = placement.y + fromOffsetY;
		visual.transition(Easing.QUAD_EASE_OUT, 0.3, props -> {
			props.x = placement.x;
			props.y = placement.y;
		}).onceComplete(this, () -> {
			visual.active = false;
		});
	}
}
