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
		var livingPlayers = players.filter(p -> p.gameState != OutOfTournament && p.gameState != Winner);

		if (livingPlayers.foreach(p -> p.gameState == ShopEquipReady)) {
			initBattlePhase(livingPlayers);
			for (p in livingPlayers) {
				if (p.gameState == ShopEquipReady)
					p.gameState = Battle;
			}
		}
		if (livingPlayers.foreach(p -> p.gameState == BattleEnded)) {
			initPhaseShopEquip();
			for (player in players) {
				if (player.gameState == BattleEnded)
					player.gameState = ShopEquip;
			}
		}
		if (livingPlayers.length <= 1) {
			for (player in livingPlayers) {
				player.gameState = Winner;
			}
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
		while (activeBattlesOrderList.length > 0) {
			var idxA = activeBattlesOrderList.pop();
			var idxB = activeBattlesOrderList.pop();
			var battle;
			if (idxB != null) {
				// TODO: HACK, the local player (first in array) is always playerA to simplify rendering
				var playerA = idxB == 0 ? livingPlayers[idxB] : livingPlayers[idxA];
				var playerB = idxB == 0 ? livingPlayers[idxA] : livingPlayers[idxB];
				if (idxB == 0)
					trace('player should have been B side -> swapped to A');
				battle = new Battle(playerA, playerB);
				trace('creating battle ${battle.idBattle} with\n  * A ${battle.playerA.playerName}\n  * B ${battle.playerB.playerName}');
				activeBattles.push(battle);
				battle.onceWinnerChange(this, (winner, _) -> {
					if (winner == null)
						throw "winner cannot be set to null";
					activeBattles.remove(battle);
					finishedBattles.push(battle);
				});
			} else {
				// there is not enough opponent, luck player gets a free win
				battle = new Battle(livingPlayers[idxA], null);
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
			player.resetEntities();
		}
		// TODO here: play AI turn
		// non humain players should by stuff and change equipments
		for (iPplayer in 1...players.length) {
			var ai = players[iPplayer];
			ai.shop.processPurchase(ai.shop.draw.first());
			ai.shop.processPurchase(ai.shop.draw.first());
			ai.shop.processPurchase(ai.shop.draw.first());
			ai.equip(ai.shelf.items.array().pickRandom(), ai.sorcerers.array().pickRandom());
			ai.equip(ai.shelf.items.array().pickRandom(), ai.sorcerers.array().pickRandom());
			ai.equip(ai.shelf.items.array().pickRandom(), ai.sorcerers.array().pickRandom());
			ai.equip(ai.shelf.items.array().pickRandom(), ai.sorcerers.array().pickRandom());
			ai.equip(ai.shelf.items.array().pickRandom(), ai.sorcerers.array().pickRandom());
		}
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
