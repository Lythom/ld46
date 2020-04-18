package ld46.model;

import tracker.Model;

class Game extends Model {
	var deck:List<SorcererItem>;
    var players:List<Player>;
    var battles:List<Battle>;

	public function new() {
		super();
		deck = new List<SorcererItem>();
		players = new List<Player>();
		battles = new List<Battle>();
		for (i in 0...8) {
			players.add(new Player("player " + Utils.randomString(6)));
		}
	}

	public function initDeck() {
		deck.clear();
		var instancesPerItem = Data.configs.get(Data.ConfigsKind.ItemsQuantitiesInDeck);
		if (instancesPerItem == null)
			throw "Please configure ItemsQuantitiesInDeck in CastleDB";
		for (item in Data.items.all) {
			if (item.enabled)
				for (i in 0...instancesPerItem.value) {
					deck.add(new SorcererItem(item));
				}
		}
    }
    
    
}
