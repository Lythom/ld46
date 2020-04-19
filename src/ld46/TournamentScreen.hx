package ld46;

import ld46.components.ShopActor;
import ld46.components.TrashActor;
import ld46.components.Board;
import ld46.components.NextRoundButton;
import ld46.components.ShelfActor;
import ld46.model.Player;
import ceramic.Assets;
import ceramic.Text;
import ceramic.Visual;

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

	public function new(assets:Assets, localPlayer:Player, allPlayers:Array<Player>) {
		super();
		this.assets = assets;
		this.localPlayer = localPlayer;
		this.allPlayers = localPlayer;

		this.itemActorDirector = new ItemActorDirector(assets);

		nextRoundButton = new NextRoundButton(assets);
		mainBoard = new Board(assets, localPlayer, this.itemActorDirector);
		trash = new TrashActor(assets);
		playersScores = new Text();

		shop = new ShopActor(assets, localPlayer.shop, itemActorDirector.getItemActor);
		shelf = new ShelfActor(assets, localPlayer.shelf, itemActorDirector.getItemActor);

		add(mainBoard);
		add(trash);
		add(shop);
		add(shelf);
		add(playersScores);
		add(nextRoundButton);

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
			if (e.keyCode == KeyCode.ESCAPE) {
				this.destroy();
				new MainMenu(assets);
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
