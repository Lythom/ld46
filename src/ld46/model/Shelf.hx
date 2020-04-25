package ld46.model;

import tracker.Model;

@:nullSafety(Off)
class Shelf extends Model {
	/**
	 * Do not manipulate directly, use put and remove instead
	 */
	@observe public var items(default, null):Array<SorcererItem>;

	public function new() {
		super();
		items = new Array<SorcererItem>();
	}

	public function put(item:SorcererItem):Bool {
		if (items.length >= Data.configs.get(ShelfSize).sure().value) 
			return false;
		items.push(item);
		this.invalidateItems();
		return true;
	}

	public function putOnHiddenTemporarySlot(item:SorcererItem):Void {
		items.push(item);
		this.invalidateItems();
	}

	public function remove(item:SorcererItem):Bool {
		var res = items.remove(item);
		if (res)
			this.invalidateItems();
		return res;
	}

	public function hasHiddenTempItem():Bool {
		return items.length > Data.configs.get(ShelfSize).sure().value;
	}
}
