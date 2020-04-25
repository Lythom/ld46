package ld46.components;

import lythom.stuffme.AttributeValues;
import ceramic.Point;
import ceramic.Assets;
import ld46.model.SorcererItem;
import ceramic.Quad;

class SorcererItemActor extends Quad {
	public var item:SorcererItem;

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

	public function update() {}

	public static function getDescription(item:SorcererItem) {
		
		var itemEffects:CalculatedStuff = (new AttributeValues()).with([item]);
		
		return ''
			+ '${(item.itemData.set != null ? '"${item.itemData.set.sure().id}" ' : ' ') + Data.Items_slot.NAMES[item.itemData.slot.toInt()]} (Level ${item.level})\n'
			// + (item.itemData.set != null ? 'Set "${item.itemData.set.sure().id}"\nSet bonus :${item.itemData.set.sure().bonusDescription}\n' : '')
			+ (item.itemData.provideRole != null ? 'PROVIDE "${item.itemData.provideRole.sure().id}": ${item.itemData.provideRole.sure().description}\n' : '')
			+ (item.itemData.provideBonus != null ? 'GIVES:\n  * ${itemEffects.items[0].bonuses.map(bd -> bd.description).join(',\n  * ')}\n' : '')
			//+ 'Id:${item.id}'
			;
	}
}
