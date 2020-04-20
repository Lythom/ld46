package ld46.model;

import tracker.Model;

@:nullSafety(Off)
class SorcererTournament extends Model {
	var deck:Array<SorcererItem>;
	var players:Array<Player>;
	var battles:Array<Battle>;
	public static var debugInstance:SorcererTournament;

	public function new() {
		super();
		deck = new Array<SorcererItem>();
		players = new Array<Player>();
		battles = new Array<Battle>();
		for (i in 0...8) {
			players.push(new Player("player " + Utils.randomString(6)));
		}
		initDeck();
		initPhaseShopEquip();
		debugInstance = this;
	}

	public function update() {
		if (players.foreach(p -> p.gameState == ShopEquipReady)) {
			for (player in players) {
				player.gameState = Battle;
			}
			initBattlePhase();
		}
		if (players.foreach(p -> p.gameState == BattleEnded)) {
			for (player in players) {
				player.gameState = ShopEquip;
			}
			initPhaseShopEquip();
		}
	}

	public function getPlayers():Array<Player> {
		return players;
	}

	public function initBattlePhase() {}

	public function initPhaseShopEquip() {
		shuffleDeck();
		for (player in players) {
			player.shop.drawItems(this);
			player.shop.credits += (player.isWinnerOfLastBattle() ? Data.configs.get(ShopWinnerPick).value : Data.configs.get(ShopLoserPick).value);
		}
		// TODO here: play AI turn
		// non humain players should by stuff and change equipments
	}

	public function initPhaseBattle() {}

	public function shuffleDeck() {
		Utils.shuffle(deck);
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
		shuffleDeck();
	}

	public function drawFromDeck(count:Int, draw:List<SorcererItem>) {
		shuffleDeck();
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
