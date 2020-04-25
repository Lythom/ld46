package ld46.model;

import haxe.ds.StringMap;
import ceramic.Assets;
import ceramic.Point;
import tracker.Model;

enum GameState {
	ShopEquip;
	ShopEquipReady;
	BattleStart(otherPlayer:Player);
	BattleEnded;
	OutOfTournament;
	Winner;
}

@:nullSafety(Off)
class Player extends Model {
	public static var PLAYER_ID = 0;

	@observe public var gameState:GameState = ShopEquip;
	@observe public var playerName:String;
	@observe public var sorcerers:Array<Sorcerer>;
	@observe public var chaleace:Chaleace;
	@observe public var battles:Array<Battle>;
	@observe public var shop:Shop;
	@observe public var shelf:Shelf;

	public var boardEntities(get, null):Array<BoardEntity>;

	@event function notifyBattleResult(isWinner:Bool);

	public function new(playerName:String) {
		super();
		this.gameState = ShopEquip;
		this.playerName = playerName + ' (' + PLAYER_ID++ + ')';
		battles = new Array<Battle>();
		sorcerers = new Array<Sorcerer>();
		chaleace = new Chaleace();
		shop = new Shop();
		shelf = new Shelf();

		chaleace.boardConfiguredX = 16;
		chaleace.boardConfiguredY = 16;

		var sorc = new Sorcerer();
		sorcerers.push(sorc);
		sorc.boardConfiguredX = 46;
		sorc.boardConfiguredY = -52;

		sorc = new Sorcerer();
		sorcerers.push(sorc);
		sorc.boardConfiguredX = 130;
		sorc.boardConfiguredY = 45;

		sorc = new Sorcerer();
		sorcerers.push(sorc);
		sorc.boardConfiguredX = -95;
		sorc.boardConfiguredY = 38;

		autorun(() -> {
			shelf.items;
		}, tryMerge);

		autorun(() -> {
			for (sorc in sorcerers) {
				sorc.fighting = gameState != ShopEquip;
				chaleace.fighting = gameState != ShopEquip;
			}
			if (gameState == ShopEquip) {
				placeOnConfiguredPositions();
			}
		});
	}

	var counts = new StringMap<Int>();

	public function tryMerge() {
		// try merge
		counts.clear();
		for (item in shelf.items) {
			var idlvl = item.itemData.id.toString() + item.level;
			counts.set(idlvl, counts.exists(idlvl) ? counts.get(idlvl) + 1 : 1);
		}
		function doMerge(merged:SorcererItem, outs:Array<SorcererItem>) {
			merged.level++;
			for (out in outs) {
				out.triggerMergeInto(merged);
				shelf.remove(out);
			}
		}
		for (idlvl => count in counts) {
			if (count >= 3) {
				var mergeables = shelf.items.filter(item -> (item.itemData.id.toString() + item.level) == idlvl);
				doMerge(mergeables.shift(), [mergeables.shift(), mergeables.shift()]);
				return;
				// TODO: when the merged item is put back into the deck, the destroyed items should be back in too !
			}
		}
		for (s in sorcerers) {
			for (item in s.items) {
				var idlvl = item.itemData.id.toString() + item.level;
				if (counts.get(idlvl) == 2) {
					// 2 on shelf, 1 on sorcerer, merge on sorcerer !
					var mergeables = shelf.items.filter(item -> (item.itemData.id.toString() + item.level) == idlvl);
					doMerge(item, [mergeables.shift(), mergeables.shift()]);
					return;
					// TODO: when the merged item is put back into the deck, the destroyed items should be back in too !
				}
			}
		}
	}

	public function tryPurchaseItem(item:SorcererItem) {
		if (!this.shop.canBuy() || item == null)
			return;
		var hasRoom = this.shelf.put(item);
		if (hasRoom) {
			this.shop.processPurchase(item);
		} else {
			trace('put on temp slot');
			this.shelf.putOnHiddenTemporarySlot(item);
			// will trigger merge if any and free the hidden slot. Else, remove it from shelf.
			if (this.shelf.hasHiddenTempItem()) {
				trace("was on shelf but has not been merged: removed.");
				this.shelf.remove(item);
				ceramic.Timer.delay(this, 0.1, () -> {
					this.shop.invalidateDraw();
				});
			}
		}
	}

	public function get_boardEntities() {
		var arr:Array<BoardEntity> = [for (s in sorcerers) s];
		arr.push(chaleace);
		return arr;
	}

	public function equip(item:SorcererItem, sorcerer:Sorcerer):Bool {
		if (item == null || sorcerer == null)
			return false;
		shelf.remove(item);
		var prev = sorcerer.equipItem(item);
		if (prev != null)
			shelf.put(prev);
		return true;
	}

	public function placeOnConfiguredPositions() {
		for (sorc in sorcerers) {
			sorc.x = sorc.boardConfiguredX;
			sorc.y = sorc.boardConfiguredY;
		}
		chaleace.x = chaleace.boardConfiguredX;
		chaleace.y = chaleace.boardConfiguredY;
	}

	public function resetEntities() {
		this.chaleace.lockIn = Data.configs.get(ChaleaceLockTimeInSec).sure().value;
		for (sorcerer in this.sorcerers) {
			sorcerer.health = sorcerer.calculatedStats.getValue(Health);
			sorcerer.attackCooldown = 0;
		}
		placeOnConfiguredPositions();
	}

	public function moveToPlayerB() {
		for (sorc in sorcerers) {
			sorc.moveToPlayerB();
		}
		chaleace.moveToPlayerB();
	}

	public function isWinnerOfLastBattle():Bool {
		var lastBattle:Null<Battle> = battles.last();
		return lastBattle == null || lastBattle.winner == this;
	}
}
