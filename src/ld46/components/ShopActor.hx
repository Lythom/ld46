package ld46.components;

import ceramic.Fonts;
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

		creditsText.pointSize = 20;
		creditsText.pos(25, -10);
		creditsText.depth = 11;
		creditsText.font = assets.font(Fonts.SIMPLY_MONO_60);
		add(creditsText);
		creditsTextBg.color = Color.BLACK;
		creditsTextBg.alpha = 0.75;
		creditsTextBg.size(260, 20);
		creditsTextBg.pos(creditsText.x - 10, creditsText.y - 5);
		creditsTextBg.depth = 10;
		add(creditsTextBg);

		autorun(() -> {
			this.creditsText.content = 'Shop - credits: ' + Std.string(shop.credits);
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
			var x = padding + actor.width / 2 + (actor.width + padding) * i;
			var y = this.height / 2;
			add(actor);
			actor.pos(x, y);
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
				actor.showDescription(-80);
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
