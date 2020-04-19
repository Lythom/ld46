package ld46.model;

import ceramic.Assets;
import ceramic.Point;
import tracker.Model;

enum GameState {
	ShopEquip;
	ShopEquipReady;
	Battle;
	BattleEnded;
}

@:nullSafety(Off)
class Player extends Model {
	@observe public var gameState:GameState = ShopEquip;
	@observe public var playerName:String;
	@observe public var sorcerers:List<Sorcerer>;
	@observe public var chaleace:Chaleace;
	@observe public var battles:List<Battle>;
	@observe public var shop:Shop;
	@observe public var shelf:Shelf;

	// configuration origin is the center of the player half field
	// positive value down and right
	// relates to positions while being bot-side. positions are mirrored if playing topside.
	var sorcerersConfiguration:Array<Point>;
	var chaleaceConfiguration:Point;

	public function new(playerName:String) {
		super();
		this.gameState = ShopEquip;
		this.playerName = playerName;
		battles = new List<Battle>();
		sorcerers = new List<Sorcerer>();
		sorcerers.add(new Sorcerer());
		sorcerers.add(new Sorcerer());
		sorcerers.add(new Sorcerer());
		chaleace = new Chaleace();
		shop = new Shop();
		shelf = new Shelf();

		chaleaceConfiguration = new Point(0, 0);
		sorcerersConfiguration = [new Point(60, 0), new Point(-20, 40), new Point(-30, 30),];
		resetPositionsToPlayerConfiguration();
	}

	public function isWinnerOfLastBattle():Bool {
		var lastBattle:Null<Battle> = battles.last();
		return lastBattle == null || lastBattle.winner == this;
	}

	public function resetPositionsToPlayerConfiguration() {
		for (idxSorc => sorc in sorcerers) {
			sorc.x = sorcerersConfiguration[idxSorc].x;
			sorc.y = sorcerersConfiguration[idxSorc].y;
		}
		chaleace.x = chaleaceConfiguration.x;
		chaleace.y = chaleaceConfiguration.y;
	}
}
