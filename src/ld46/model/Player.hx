package ld46.model;

import haxe.ds.StringMap;
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

	public function new(playerName:String) {
		super();
		this.gameState = ShopEquip;
		this.playerName = playerName;
		battles = new List<Battle>();
		sorcerers = new List<Sorcerer>();
		chaleace = new Chaleace();
		shop = new Shop();
		shelf = new Shelf();

		var sorc = new Sorcerer();
		sorcerers.add(sorc);
		sorc.boardConfiguredX = 120;
		sorc.boardConfiguredY = 0;

		sorc = new Sorcerer();
		sorcerers.add(sorc);
		sorc.boardConfiguredX = -40;
		sorc.boardConfiguredY = 80;

		sorc = new Sorcerer();
		sorcerers.add(sorc);
		sorc.boardConfiguredX = -30;
		sorc.boardConfiguredY = 30;

		var counts = new StringMap<Int>();
		shelf.onItemsChange(this, (current, _) -> {
			counts.clear();
			for (item in current) {
				var id = item.itemData.id.toString();
				counts.set(id, counts.exists(id) ? counts.get(id) + 1 : 1);
			}
			for (id => count in counts) {
				if (count >= 3) {
					var mergeables = current.filter(item -> item.itemData.id.toString() == id);
					var merged = mergeables.pop();
					merged.level++;
					var outs = [mergeables.pop(), mergeables.pop()];
					for (out in outs) {
						shelf.remove(out);
						out.triggerMergeInto(merged);
					}
				}
			}
		});

		autorun(() -> {
			for (sorc in sorcerers) {
				sorc.fighting = gameState != ShopEquip;
				chaleace.fighting = gameState != ShopEquip;
			}
			if (gameState == ShopEquip) {
				for (sorc in sorcerers) {
					sorc.x = sorc.boardConfiguredX;
					sorc.y = sorc.boardConfiguredY;
				}
				chaleace.x = chaleace.boardConfiguredX;
				chaleace.y = chaleace.boardConfiguredY;
			}
		});
	}

	public function isWinnerOfLastBattle():Bool {
		var lastBattle:Null<Battle> = battles.last();
		return lastBattle == null || lastBattle.winner == this;
	}
}
