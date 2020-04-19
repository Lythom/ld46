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
		returnItems(game);
		game.drawFromDeck(Data.configs.get(ShopDrawCount).sure().value, this.draw);
		this.invalidateDraw();
	}

	public function returnItems(game:SorcererTournament) {
		game.returnToDeck(draw);
		this.invalidateDraw();
	}

	public function canBuy():Bool {
		return credits > 0;
	}

	public function processPurchase(item:SorcererItem):Bool {
		if (!canBuy())
			return false;
		credits --;
		var result = draw.remove(item);
		this.invalidateDraw();
		return result;
	}
}
