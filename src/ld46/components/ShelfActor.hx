package ld46.components;

import ceramic.Easing;
import ld46.model.SorcererItem;
import ld46.model.Shelf;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;
import ceramic.Shortcuts.*;

@:nullSafety(Off)
class ShelfActor extends Quad {
	private var assets:Assets;
	private var getItemActor:SorcererItem->SorcererItemActor;
	private var items:List<SorcererItemActor>;

	public var shelf:Shelf;

	/**
	 * If the item was dropped somewhere.
	 */
	@event function dropItemAt(itemAction:SorcererItemActor, x:Float, y:Float):Void;

	public function new(assets:Assets, shelf:Shelf, getItemActor:SorcererItem->SorcererItemActor) {
		super();
		this.assets = assets;
		this.shelf = shelf;
		this.getItemActor = getItemActor;
		this.items = shelf.items.map(item -> getItemActor(item));
		refreshItems(shelf.items, null);
		this.texture = assets.texture(Images.PRELOAD__SHELF);

		shelf.onItemsChange(this, refreshItems);
	}

	function refreshItems(newDraw:List<SorcererItem>, previousDraw:Null<List<SorcererItem>>) {
		this.items = newDraw.map(item -> getItemActor(item));
		var padding = Data.placements.get(ShelfPadding).sure().x;
		for (i => actor in this.items) {
			this.add(actor);
			var x = padding + actor.width / 2 + (actor.width + padding) * i;
			var y = this.height / 2;
			if (actor.x != x || actor.y != y) {
				actor.transition(Easing.QUAD_EASE_OUT, 0.25, props -> {
					props.x = x;
					props.y = y;
				});
			}
			actor.offPointerDown();
			actor.onPointerDown(this, downEvt -> {
                var startX = actor.x;
                var startY = actor.y;
				var handleMouseMove = (x:Float, y:Float) -> actor.pos(x - this.x, y - this.y);
				screen.onMouseMove(this, handleMouseMove);
				screen.oncePointerUp(this, upEvt -> {
					screen.offMouseMove(handleMouseMove);
					this.emitDropItemAt(actor, upEvt.x, upEvt.y);
					if (this.items.has(actor)) {
						actor.transition(Easing.QUAD_EASE_OUT, 0.15, props -> props.pos(startX, startY));
					};
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
		}
	}
}
