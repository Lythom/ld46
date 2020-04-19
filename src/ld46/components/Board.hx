package ld46.components;

import ceramic.Point;
import ld46.TournamentScreen.ItemActorFactory;
import ceramic.Images;
import ld46.model.Player;
import ceramic.Assets;
import ceramic.Quad;
import ceramic.Shortcuts.*;

class Board extends Quad {
	var sorcerers:Array<SorcererActor>;
	var chaleace:ChaleaceActor;

	public function new(assets:Assets, player:Player, iaf:ItemActorFactory) {
		super();
		sorcerers = new Array<SorcererActor>();
		chaleace = new ChaleaceActor(assets, player.chaleace);
		this.texture = assets.texture(Images.PRELOAD__MAIN_BOARD);
		this.anchor(0.5, 0.5);
		this.depth = 2000;

		for (sorcerer in player.sorcerers) {
			var actor = new SorcererActor(assets, sorcerer, iaf);
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
	}
	
}
