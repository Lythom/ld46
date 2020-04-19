package ld46.components;

import ceramic.Easing;
import ld46.model.SorcererItem;
import ceramic.Text;
import ld46.model.Shop;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;

@:nullSafety(Off)
class ShopActor extends Quad {
	private var assets:Assets;
	private var shop:Shop;
	private var creditsText:Text;
	private var items:List<SorcererItemActor>;

	private var getItemActor:SorcererItem->SorcererItemActor;

	@event function purchaseItem(item:SorcererItem):Void;

	public function new(assets:Assets, shop:Shop, getItemActor:SorcererItem->SorcererItemActor) {
		super();
		this.assets = assets;
		this.shop = shop;
		this.getItemActor = getItemActor;
		this.creditsText = new Text();
		this.items = shop.draw.map(item -> getItemActor(item));

		refreshItems(shop.draw, null);
		this.texture = assets.texture(Images.PRELOAD__SHOP);

		this.shop.onCreditsChange(this, (credits, _) -> {
			this.creditsText.content = Std.string(credits);
		});
		this.shop.onDrawChange(this, refreshItems);
	}

	function refreshItems(newDraw:List<SorcererItem>, previousDraw:Null<List<SorcererItem>>) {
		var padding = Data.placements.get(ShelfPadding).sure().x;
		this.items = newDraw.map(item -> getItemActor(item));
		for (i => actor in this.items) {
			var x = padding + (actor.texture.width + padding) * i;
			var y = this.texture.height / 2;
			if (actor.x != x || actor.y != y) {
				actor.transition(Easing.QUAD_EASE_IN_OUT, 0.15, props -> {
					props.x = x;
					props.y = y;
				});
			}
			actor.offPointerUp();
			actor.onPointerUp(this, evt -> {
				this.emitPurchaseItem(actor.item);
			});
		}
	}
}
