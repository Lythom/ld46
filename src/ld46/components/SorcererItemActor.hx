package ld46.components;

import ceramic.Easing;
import lythom.stuffme.AttributeValues;
import ceramic.Point;
import ceramic.Assets;
import ld46.model.SorcererItem;
import ceramic.Quad;

enum OutTransition {
	Reduce;
	Cut;
}

class SorcererItemActor extends Quad {
	public var item:SorcererItem;

	public var outTransition:OutTransition = Reduce;

	private var description:Description;
	private var assets:Assets;

	public function new(assets:Assets, item:SorcererItem) {
		super();
		this.item = item;
		this.assets = assets;
		this.description = new Description(getDescription(item));

		HotLoader.instance.onReload(this, loadContent);
		loadContent();

		autorun(() -> {
			description.text.content = getDescription(item);
			switch (item.level) {
				case 1:
					description.text.color = ceramic.Color.WHITE;
					description.color = ceramic.Color.BLACK;
					this.color = ceramic.Color.WHITE;
				case 2:
					description.text.color = ceramic.Color.CYAN;
					description.color = ceramic.Color.PURPLE;
					this.color = ceramic.Color.fromHSLuv(207, 1, 70);
				case 3:
					description.text.color = ceramic.Color.YELLOW;
					description.color = ceramic.Color.ORANGE;
					this.color = ceramic.Color.fromHSLuv(76, 1, 70);
				default:
			}
		});
	}

	public function loadContent() {
		this.texture = assets.textureFromFile(item.itemData.image);
		this.size(100, 100);
		this.anchor(0.5, 0.5);
		this.description.text.content = getDescription(this.item);
		description.active = false;
	}

	public function showDescription(contextOffsetX:Float = 0) {
		var leftLimit = new Point();
		/// where is the left point on (or out) screen ?
		this.visualToScreen(this.width * 0.8 - description.width + contextOffsetX, -description.width, leftLimit);
		var offsetX = leftLimit.x < 20 ? -leftLimit.x + 20 : 0;
		var offsetY = leftLimit.y < 20 ? -leftLimit.y + 20 : 0;
		var p = new Point();
		this.visualToScreen(this.width * 0.8 + offsetX + contextOffsetX, offsetY, p);
		description.pos(p.x, p.y);
		description.alpha = 0.7;
		description.depth = 9999;
		description.active = true;
	}

	public function hideDescription() {
		description.active = false;
	}

	public function disappear(delta:Float):Void {
		if (this.destroyed)
			return;

		// grow to anticipate action
		this.scale(1, 1);
		this.transition(Easing.QUAD_EASE_OUT, 0.1, props -> {
			props.scale(1.2, 1.2);
		}).run(tween -> tween.onComplete(this, () -> {
			// action time, either destroy or reset size
			if (this != null && this.parent == null) {
				switch outTransition {
					case Reduce:
						this.transition(Easing.QUAD_EASE_OUT, 0.2, props -> {
							props.scale(0.2, 0.2);
							props.alpha = 0.2;
						}).run(tweenOut -> tweenOut.onComplete(this, () -> {
							this.active = false;
							this.scale(1, 1);
							this.alpha = 1;
						}));
					case Cut:
						this.active = false;
				}
			} else {
				// reset props and let new parent do the lead
				this.transition(Easing.QUAD_EASE_OUT, 0.1, props -> {
					props.scale(1, 1);
				});
			}
		}));
	}

	public static function getDescription(item:SorcererItem) {
		var itemEffects:CalculatedStuff = (new AttributeValues()).with([item]);

		return ''
			+
			'${(item.itemData.set != null ? '"${item.itemData.set.sure().id}" ' : ' ') + Data.Items_slot.NAMES[item.itemData.slot.toInt()]} (Level ${item.level})\n' // + (item.itemData.set != null ? 'Set "${item.itemData.set.sure().id}"\nSet bonus :${item.itemData.set.sure().bonusDescription}\n' : '')
			+ (item.itemData.provideRole != null ? 'PROVIDE "${item.itemData.provideRole.sure().id}": ${item.itemData.provideRole.sure().description}\n' : '')
			+
			(item.itemData.provideBonus != null ? 'GIVES:\n  * ${itemEffects.items[0].bonuses.map(bd -> bd.description).join(',\n  * ')}\n' : '') // + 'Id:${item.id}'
			;
	}
}
