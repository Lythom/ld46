package ld46.components;

import ceramic.Fonts;
import ceramic.Point;
import ceramic.Easing;
import ld46.model.SorcererItem;
import ld46.model.Shelf;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;
import ceramic.Text;
import ceramic.Color;
import ceramic.Shortcuts.*;

@:nullSafety(Off)
class ShelfActor extends Quad {
	private var assets:Assets;
	private var itemActorDirector:ItemActorDirector;
	private var items:Array<SorcererItemActor>;

	private var creditsText:Text;
	private var creditsTextBg:Quad;

	public var shelf:Shelf;

	/**
	 * If the item was dropped somewhere.]
	 * @param itemAction
	 * @param x
	 * @param y
	 */
	@event function dropItemAt(itemAction:SorcererItemActor, x:Float, y:Float):Void;

	/**
	 * Item is being dragged at position.
	 * @param itemAction itemAction
	 * @param x x
	 * @param y y
	 */
	@event function moveItemAt(itemAction:SorcererItemActor, x:Float, y:Float):Void;

	public function new(assets:Assets, shelf:Shelf, itemActorDirector:ItemActorDirector) {
		super();
		this.assets = assets;
		this.shelf = shelf;
		this.itemActorDirector = itemActorDirector;
		this.items = shelf.items.map(item -> itemActorDirector.getItemActor(item));
		this.creditsText = new Text();
		this.creditsTextBg = new Quad();

		creditsText.pointSize = 20;
		creditsText.pos(25, -10);
		creditsText.depth = 11;
		creditsText.font = assets.font(Fonts.SIMPLY_MONO_60);
		creditsText.content = 'Shelf - Drag and drop items to sorcerers or trash';
		add(creditsText);
		creditsTextBg.color = Color.BLACK;
		creditsTextBg.alpha = 0.75;
		creditsTextBg.size(650, 30);
		creditsTextBg.pos(creditsText.x - 10, creditsText.y - 5);
		creditsTextBg.depth = 10;
		add(creditsTextBg);

		refreshItems(shelf.items, null);
		this.texture = assets.texture(Images.PRELOAD__SHELF);

		shelf.onItemsChange(this, refreshItems);
	}

	function refreshItems(newDraw:Array<SorcererItem>, previousDraw:Null<Array<SorcererItem>>) {
		this.items = newDraw.map(item -> itemActorDirector.getItemActor(item));
		var padding = Data.placements.get(ShelfPadding).sure().x;
		var deletes = this.children == null ? [] : this.children.filter(child -> child != null && Std.is(child, SorcererItemActor)
			&& !this.items.has(cast child));
		for (deleteMe in deletes) {
			this.remove(deleteMe);
			ceramic.Timer.delay(this, 0.5, () -> itemActorDirector.giveBack(cast deleteMe));
		}
		var i = 0;
		for (actor in this.items) {
			var from = new Point();
			actor.visualToScreen(0, 0, from);
			this.add(actor);
			this.screenToVisual(from.x, from.y, from);
			actor.pos(from.x + actor.width * actor.anchorX, from.y + actor.height * actor.anchorY);
			var x = padding + actor.width / 2 + (actor.width + padding) * i;
			var y = this.height / 2;
			if (actor.x != x || actor.y != y) {
				actor.transition(Easing.QUAD_EASE_OUT, 0.45, props -> {
					props.x = x;
					props.y = y;
				});
			}
			actor.offPointerDown();
			actor.onPointerDown(this, downEvt -> {
				var startX = actor.x;
				var startY = actor.y;
				actor.hideDescription();
				var handleMouseMove = (x:Float, y:Float) -> {
					actor.pos(x - this.x, y - this.y);
					this.emitMoveItemAt(actor, x, y);
				}
				screen.onMouseMove(this, handleMouseMove);
				screen.oncePointerUp(this, upEvt -> {
					screen.offMouseMove(handleMouseMove);
					this.emitDropItemAt(actor, upEvt.x, upEvt.y);
					app.onceUpdate(this, delta -> {
						if (!actor.destroyed && this.items.has(actor)) {
							actor.transition(Easing.QUAD_EASE_OUT, 0.15, props -> props.pos(startX, startY));
						};
					});
				});
			});
			actor.offPointerOver();
			actor.onPointerOver(this, evy -> {
				actor.transition(Easing.QUAD_EASE_OUT, 0.15, props -> {
					props.scaleX = 1.1;
					props.scaleY = 1.1;
				});
				actor.showDescription();
			});
			actor.offPointerOut();
			actor.onPointerOut(this, evt -> {
				actor.transition(Easing.QUAD_EASE_IN_OUT, 0.15, props -> {
					props.scaleX = 1;
					props.scaleY = 1;
				});
				actor.hideDescription();
			});
			i++;
		}
	}
}
