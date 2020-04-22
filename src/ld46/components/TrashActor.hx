package ld46.components;

import ld46.model.SorcererItem;
import ld46.model.Shelf;
import ceramic.Images;
import ceramic.Assets;
import ceramic.Quad;

@:nullSafety(Off)
class TrashActor extends Quad {
	private var assets:Assets;

	@event function throwItem(item:SorcererItem):Void;

	public function new(assets:Assets, shelf:ShelfActor) {
		super();
		this.assets = assets;
		this.texture = assets.texture(Images.PRELOAD__TRASH);

		this.scale(0.6, 0.6);

		this.onPointerOver(this, evt -> {
			this.scale(0.7, 0.7);
		});
		this.onPointerOut(this, evt -> {
			this.scale(0.6, 0.6);
		});

		shelf.onDropItemAt(this, (itemActor, x, y) -> {
			if (this.hits(x, y)) {
				this.emitThrowItem(itemActor.item);
				this.scale(0.6, 0.6);
			}
		});

		shelf.onMoveItemAt(this, (itemActor, x, y) -> {
			if (this.hits(x, y)) {
				this.scale(0.7, 0.7);
			} else {
				this.scale(0.6, 0.6);
			}
		});
	}
}
