package ld46.components;

import ld46.model.Sorcerer;
import ceramic.Images;
import ceramic.Point;
import ld46.ItemActorDirector;
import ld46.model.Player;
import ceramic.Assets;
import ceramic.Quad;
import ceramic.Shortcuts.*;

class BoardActor extends Quad {
	var sorcerers:Array<SorcererActor>;
	var chaleace:ChaleaceActor;

	public function new(assets:Assets, player:Player, iaf:ItemActorDirector, shelf:Null<ShelfActor>) {
		super();
		sorcerers = new Array<SorcererActor>();
		chaleace = new ChaleaceActor(assets, player.chaleace);
		add(chaleace);

		this.texture = assets.texture(Images.PRELOAD__MAIN_BOARD);
		this.anchor(0.5, 0.5);
		var isLocalPlayer = shelf != null;

		for (sorcerer in player.sorcerers) {
			var actor = new SorcererActor(assets, sorcerer, iaf);
			add(actor);
			sorcerers.push(actor);
			if (isLocalPlayer) {
				actor.onPointerDown(this, evt -> {
					if (!actor.sorcerer.fighting) {
						var startOffset = new Point();
						var targetPositionOnBoard = new Point();
						actor.screenToVisual(evt.x, evt.y, startOffset);
						var handleMove = (x:Float, y:Float) -> {
							if (sorcerer != null && this.hits(x, y)) {
								actor.description.active = false;
								var screenTargetX = x - startOffset.x + actor.anchorX * actor.width;
								var screenTargetY = y - startOffset.y + actor.anchorY * actor.height;
								this.screenToVisual(screenTargetX, screenTargetY, targetPositionOnBoard);
								sorcerer.boardConfigured(targetPositionOnBoard.x - this.width * 0.5, targetPositionOnBoard.y - this.height * 0.5);
							}
						}
						screen.onMouseMove(this, handleMove);
						screen.oncePointerUp(this, upEvt -> {
							screen.offMouseMove(handleMove);
						});
					}
				});
			}
		}
		if (isLocalPlayer) {
			chaleace.onPointerDown(this, evt -> {
				if (!chaleace.chaleace.fighting) {
					var startOffset = new Point();
					var targetPositionOnBoard = new Point();
					chaleace.screenToVisual(evt.x, evt.y, startOffset);
					var handleMove = (x:Float, y:Float) -> {
						if (chaleace != null && chaleace.chaleace != null && this.hits(x, y)) {
							var screenTargetX = x - startOffset.x + chaleace.anchorX * chaleace.width;
							var screenTargetY = y - startOffset.y + chaleace.anchorY * chaleace.height;
							this.screenToVisual(screenTargetX, screenTargetY, targetPositionOnBoard);
							chaleace.chaleace.boardConfigured(targetPositionOnBoard.x - this.width * 0.5, targetPositionOnBoard.y - this.height * 0.5);
						}
					}
					screen.onMouseMove(this, handleMove);
					screen.oncePointerUp(this, upEvt -> {
						screen.offMouseMove(handleMove);
					});
				}
			});
		}

		var p = new Point();
		app.onUpdate(this, delta -> {
			if (this.active) {
				var localOffsetX = (isLocalPlayer ? 0 : -398);
				var localOffsetY = (isLocalPlayer ? 0 : 173);
				for (sorcererA in sorcerers) {
					sorcererA.pos(sorcererA.sorcerer.x + this.width * 0.5 + localOffsetX, sorcererA.sorcerer.y + this.height * 0.5 + localOffsetY);
					sorcererA.visualToScreen(0, 0, p);
					sorcererA.updateDepth(1000 + p.y);
				}
				chaleace.pos(chaleace.chaleace.x + this.width * 0.5 + localOffsetX, chaleace.chaleace.y + this.height * 0.5 + localOffsetY);
				chaleace.visualToScreen(0, 0, p);
				chaleace.updateDepth(1000 + p.y);
			}
		});

		if (shelf != null) {
			shelf.onDropItemAt(this, (itemActor, x, y) -> {
				var sorc = getClosest(x, y);
				if (sorc != null && shelf != null) {
					player.equip(itemActor.item, sorc.sorcerer);
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
	}

	override function destroy() {
		for (actor in this.sorcerers) {
			actor.destroy();
		}
		chaleace.destroy();
		super.destroy();
	}

	public function setActive(active:Bool) {
		this.active = active;
		for (sorcererA in sorcerers) {
			sorcererA.active = active;
		}
		chaleace.active = active;
	}

	function getClosest(screenX:Float, screenY:Float):Null<SorcererActor> {
		var bestDist:Float = Data.configs.get(SorcererDropDistanceSnap).sure().value;
		var sorc:Null<SorcererActor> = null;
		var sorcScreenPos = new Point();
		for (sorcererA in sorcerers) {
			sorcererA.visualToScreen(sorcererA.width * 0.5, sorcererA.height * 0.5, sorcScreenPos);
			var dist = LD46Utils.distance(screenX, screenY, sorcScreenPos.x, sorcScreenPos.y);
			if (dist < bestDist) {
				sorc = sorcererA;
				bestDist = dist;
			}
		}
		return sorc;
	}
}
