package ld46.components;

import ceramic.Easing;
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
		add(description);
		HotLoader.instance.onReload(this, loadContent);
		loadContent();
	}

	public function loadContent() {
		this.texture = assets.textureFromFile(item.itemData.image);
		this.size(100, 100);
		this.anchor(0.5, 0.5);
		this.description.text.content = getDescription(this.item);
		description.active = false;
	}

	public function showDescription() {
		var leftLimit = new Point();
		/// where is the left point on (or out) screen ?
		this.visualToScreen(this.width * 0.8 - description.width, 0, leftLimit);
		var offset = leftLimit.x < 20 ? -leftLimit.x + 20 : 0;
		description.pos(this.width * 0.8 + offset, 0);
		description.alpha = 0.8;
		description.active = true;
	}

	public function hideDescription() {
		description.active = false;
	}

	public function update() {}

	static function getDescription(item:SorcererItem) {
		return ''
			+ 'Slot: ${Data.Items_slot.NAMES[item.itemData.slot.toInt()]}\n'
			+ (item.itemData.set != null ? 'Set "${item.itemData.set.sure().id}"\nSet bonus :${item.itemData.set.sure().bonusDescription}\n' : '')
			+ (item.itemData.provideRole != null ? 'Provide "${item.itemData.provideRole.sure().id}"\n' : '')
			+ (item.itemData.provideBonus != null ? 'Gives:\n  * ${item.itemData.provideBonus.map(getBonusDescription).join(',\n  * ')}\n' : '')
			+ 'Id:${item.id}';
	}

	static function getBonusDescription(bonus:Data.Items_provideBonus) {
		return
			'${bonus.statId}: ${bonus.flatValue == 0 ? '' : Std.string(bonus.flatValue)}${bonus.percentValue == 0 ? '' : Std.string(bonus.flatValue * 100)}%';
	}
}
