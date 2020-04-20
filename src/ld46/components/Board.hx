package ld46.components;

import ceramic.Images;
import ceramic.Point;
import ld46.ItemActorDirector;
import ld46.model.Player;
import ceramic.Assets;
import ceramic.Quad;
import ceramic.Shortcuts.*;

class Board extends Quad {
	var sorcerers:Array<SorcererActor>;
	var chaleace:ChaleaceActor;

	public function new(assets:Assets, player:Player, iaf:ItemActorDirector, shelf:ShelfActor) {
		super();
		sorcerers = new Array<SorcererActor>();
		chaleace = new ChaleaceActor(assets, player.chaleace);
		this.texture = assets.texture(Images.PRELOAD__MAIN_BOARD);
		this.anchor(0.5, 0.5);

		for (sorcerer in player.sorcerers) {
			var actor = new SorcererActor(assets, sorcerer, iaf, shelf);
			sorcerers.push(actor);
			add(actor);
			actor.onPointerDown(this, evt -> {
				if (!actor.sorcerer.fighting) {
					var startOffset = new Point();
					var targetPositionOnBoard = new Point();
					actor.screenToVisual(evt.x, evt.y, startOffset);
					var handleMove = (x:Float, y:Float) -> {
						if (this.hits(x, y)) {
							var screenTargetX = x - startOffset.x + actor.anchorX * actor.width;
							var screenTargetY = y - startOffset.y + actor.anchorY * actor.height;
							this.screenToVisual(screenTargetX, screenTargetY, targetPositionOnBoard);
							sorcerer.boardConfiguredX = targetPositionOnBoard.x - this.width * 0.5;
							sorcerer.boardConfiguredY = targetPositionOnBoard.y - this.height * 0.5;
						}
					}
					screen.onMouseMove(this, handleMove);
					screen.oncePointerUp(this, upEvt -> {
						screen.offMouseMove(handleMove);
					});
				}
			});
		}
		add(chaleace);
		chaleace.onPointerDown(this, evt -> {
			if (!chaleace.chaleace.fighting) {
				var startOffset = new Point();
				var targetPositionOnBoard = new Point();
				chaleace.screenToVisual(evt.x, evt.y, startOffset);
				var handleMove = (x:Float, y:Float) -> {
					if (this.hits(x, y)) {
						var screenTargetX = x - startOffset.x + chaleace.anchorX * chaleace.width;
						var screenTargetY = y - startOffset.y + chaleace.anchorY * chaleace.height;
						this.screenToVisual(screenTargetX, screenTargetY, targetPositionOnBoard);
						chaleace.chaleace.boardConfiguredX = targetPositionOnBoard.x - this.width * 0.5;
						chaleace.chaleace.boardConfiguredY = targetPositionOnBoard.y - this.height * 0.5;
					}
				}
				screen.onMouseMove(this, handleMove);
				screen.oncePointerUp(this, upEvt -> {
					screen.offMouseMove(handleMove);
				});
			}
		});

		autorun(() -> {
			for (sorcererA in sorcerers) {
				sorcererA.pos(sorcererA.sorcerer.x + this.width * 0.5, sorcererA.sorcerer.y + this.height * 0.5);
				sorcererA.depth = sorcererA.y;
			}
			chaleace.pos(chaleace.chaleace.x + this.width * 0.5, chaleace.chaleace.y + this.height * 0.5);
			chaleace.depth = chaleace.y;
		});

		shelf.onDropItemAt(this, (itemActor, x, y) -> {
			var sorc = getClosest(x, y);
			if (sorc != null) {
				shelf.shelf.remove(itemActor.item);
				var prev = sorc.sorcerer.equipItem(itemActor.item);
				if (prev != null)
					shelf.shelf.put(prev);
			}
		});

		shelf.onMoveItemAt(this, (itemActor, x, y) -> {
			for (sorcererA in sorcerers) {
				var item = sorcererA.getItemOnSlot(itemActor.item.itemData.slot);
				if (item != null) {
					item.scale(1, 1);
				}
			}
			var sorc = getClosest(x, y);
			if (sorc != null) {
				var item = sorc.getItemOnSlot(itemActor.item.itemData.slot);
				if (item != null) {
					item.scale(1.2, 1.2);
				}
			}
		});
	}

	function getClosest(screenX:Float, screenY:Float):Null<SorcererActor> {
		var bestDist:Float = Data.configs.get(SorcererDropDistanceSnap).sure().value;
		var sorc:Null<SorcererActor> = null;
		var sorcScreenPos = new Point();
		for (sorcererA in sorcerers) {
			sorcererA.visualToScreen(sorcererA.width * 0.5, sorcererA.height * 0.5, sorcScreenPos);
			var dist = distance(screenX, screenY, sorcScreenPos.x, sorcScreenPos.y);
			if (dist < bestDist) {
				sorc = sorcererA;
				bestDist = dist;
			}
		}
		return sorc;
	}

	function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		var a = x2 - x1;
		var b = y2 - y1;
		return Math.sqrt(a * a + b * b);
	}
}
