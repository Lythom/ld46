package ld46.components;

import ceramic.Point;
import ceramic.Color;
import ceramic.Easing;
import ld46.model.SorcererItem;
import ceramic.Text;
import ld46.model.Shop;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;
import ceramic.Shortcuts.*;

@:nullSafety(Off)
class ShopActor extends Quad {
	private var assets:Assets;
	private var shop:Shop;
	private var creditsText:Text;
	private var creditsTextBg:Quad;
	private var items:List<SorcererItemActor>;

	private var itemActorDirector:ItemActorDirector;

	@event function purchaseItem(item:SorcererItem):Void;

	public function new(assets:Assets, shop:Shop, itemActorDirector:ItemActorDirector) {
		super();
		this.assets = assets;
		this.shop = shop;
		this.itemActorDirector = itemActorDirector;
		this.creditsText = new Text();
		this.creditsTextBg = new Quad();
		this.items = shop.draw.map(item -> itemActorDirector.getItemActor(item));
		this.texture = assets.texture(Images.PRELOAD__SHOP);

		refreshItems(shop.draw, null);

		creditsText.pointSize = 30;
		creditsText.pos(this.width - creditsText.width / 2 - 10, -creditsText.height - 10);
		creditsText.depth = 11;
		add(creditsText);
		creditsTextBg.color = Color.BLACK;
		creditsTextBg.alpha = 0.8;
		creditsTextBg.size(40, 40);
		creditsTextBg.pos(creditsText.x, creditsText.y);
		creditsTextBg.depth = 10;
		add(creditsTextBg);

		autorun(() -> {
			this.creditsText.content = Std.string(shop.credits);
		});
		this.shop.onDrawChange(this, refreshItems);
	}

	function refreshItems(newDraw:List<SorcererItem>, previousDraw:Null<List<SorcererItem>>) {
		var padding = Data.placements.get(ShelfPadding).sure().x;
		this.items = shop.draw.map(item -> itemActorDirector.getItemActor(item));
		var deletes = this.children == null ? [] : this.children.filter(child -> child != null && Std.is(child, SorcererItemActor)
			&& !this.items.has(cast child));
		for (deleteMe in deletes) {
			this.remove(deleteMe);
			itemActorDirector.giveBack(cast deleteMe);
		}
		for (i => actor in this.items) {
			var from = new Point();
			actor.visualToScreen(0,0, from);
			this.add(actor);
			this.screenToVisual(from.x, from.y, from);
			actor.pos(from.x + actor.width * actor.anchorX, from.y + actor.height * actor.anchorY);
			var x = padding + actor.width / 2 + (actor.width + padding) * i;
			var y = this.height / 2;
			if (!actor.destroyed && (actor.x != x || actor.y != y)) {
				actor.transition(Easing.QUAD_EASE_IN_OUT, 0.25, props -> {
					props.x = x;
					props.y = y;
				});
			}
			actor.offPointerDown();
			actor.onPointerDown(this, evt -> {
				screen.oncePointerUp(this, evt -> {
					if (actor.hits(evt.x, evt.y))
						this.emitPurchaseItem(actor.item);
				});
			});
			actor.offPointerOver();
			actor.onPointerOver(this, evt -> {
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
		trace(this.children == null ? 'null' : '' + this.children.length);
	}
}
