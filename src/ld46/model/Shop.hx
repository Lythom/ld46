package ld46.model;

import tracker.Model;

@:nullSafety(Off)
class Shop extends Model {
	@observe public var draw:List<SorcererItem>;
	@observe public var credits:Int = 0;

	public function new() {
		super();
		draw = new List<SorcererItem>();
	}

	public function drawItems(game:SorcererTournament) {
		game.drawFromDeck(Data.configs.get(ShopDrawCount).sure().value, this.draw);
		this.dirty = true;
	}

	public function returnItems(game:SorcererTournament) {
		game.returnToDeck(draw);
		this.dirty = true;
	}

	public function buy(item:SorcererItem):Bool {
		var result = draw.remove(item);
		this.dirty = true;
		return result;
	}
}
