package ld46.model;

import ceramic.Point;
import tracker.Model;
import ceramic.Shortcuts.*;

using ld46.LD46Utils;

@:nullSafety(Off)
class SorcererTournament extends Model {
	var deck:Array<SorcererItem>;
	var players:Array<Player>;
	var activeBattles:Array<Battle>;
	var finishedBattles:Array<Battle>;

	public static var debugInstance:SorcererTournament;

	public function new() {
		super();
		deck = new Array<SorcererItem>();
		players = new Array<Player>();
		activeBattles = new Array<Battle>();
		finishedBattles = new Array<Battle>();
		for (i in 0...8) {
			players.push(new Player("player " + LD46Utils.randomString(6)));
		}
		initDeck();
		initPhaseShopEquip();
		debugInstance = this;

		app.onUpdate(this, update);
	}

	public function update(delta:Float) {
		trace(players.map(p -> p.gameState).join(','));
		if (players.foreach(p -> p.gameState == ShopEquipReady || p.gameState == OutOfTournament)) {
			var livingPlayers = players.filter(p -> p.chaleace.health > 0);
			initBattlePhase(livingPlayers);
			for (p in livingPlayers) {
				p.gameState = Battle;
			}
		}
		if (players.foreach(p -> p.gameState == BattleEnded || p.gameState == OutOfTournament)) {
			initPhaseShopEquip();
			for (player in players) {
				player.gameState = ShopEquip;
			}
		}
		if (players.count(p -> p.gameState == OutOfTournament) >= players.length - 1) {
			app.offUpdate(update);
		}
		for (battle in activeBattles) {
			battle.tick(delta);
		}
	}

	public function getPlayers():Array<Player> {
		return players;
	}

	public function initBattlePhase(livingPlayers:Array<Player>) {
		// clear the shops
		for (player in players) {
			player.shop.returnItems(this);
		}

		var activeBattlesOrderList = [for (i in 0...livingPlayers.length) i].shuffle();
		trace(activeBattlesOrderList.join(','));
		for (i in 0...Math.floor(livingPlayers.length / 2)) {
			var battle:Battle;
			if (i < activeBattlesOrderList.length - 1) {
				battle = new Battle(livingPlayers[activeBattlesOrderList[i]], livingPlayers[activeBattlesOrderList[i + 1]]);
				trace('creating battle ${battle.idBattle} with ${battle.playerA.playerName} (${activeBattlesOrderList[i]}) and ${battle.playerA.playerName} (${activeBattlesOrderList[i + 1]})');
				activeBattles.push(battle);
				battle.onceWinnerChange(this, (winner, _) -> {
					if (winner == null)
						throw "winner cannot be set to null";
					activeBattles.remove(battle);
					finishedBattles.push(battle);
				});
			} else {
				// there is not enough opponent, luck player gets a free win
				battle = new Battle(livingPlayers[activeBattlesOrderList[i]], null);
				finishedBattles.push(battle);
			}
			battle.playerA.battles.push(battle);
			if (battle.playerB != null)
				battle.playerB.battles.push(battle);
		}
	}

	public function initPhaseShopEquip() {
		deck.shuffle();
		for (player in players) {
			player.shop.drawItems(this);
			player.shop.credits += (player.isWinnerOfLastBattle() ? Data.configs.get(ShopWinnerPick).value : Data.configs.get(ShopLoserPick).value);
		}
		// TODO here: play AI turn
		// non humain players should by stuff and change equipments
	}

	public function initDeck() {
		deck = new Array<SorcererItem>();
		var instancesPerItem = Data.configs.get(Data.ConfigsKind.ItemsQuantitiesInDeck);
		if (instancesPerItem == null)
			throw "Please configure ItemsQuantitiesInDeck in CastleDB";
		for (item in Data.items.all) {
			if (item.enabled) {
				for (i in 0...instancesPerItem.value) {
					deck.push(new SorcererItem(item));
				}
			}
		}
		deck.shuffle();
	}

	public function drawFromDeck(count:Int, draw:List<SorcererItem>) {
		deck.shuffle();
		for (i in 0...count) {
			var item = deck.pop();
			if (item != null)
				draw.add(item);
		}
	}

	public function returnToDeck(draw:List<SorcererItem>) {
		for (item in draw) {
			deck.push(item);
		}
		draw.clear();
	}

	public function returnOneToDeck(item:SorcererItem) {
		deck.push(item);
	}
}
