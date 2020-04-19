package ld46.model;

import tracker.Model;

@:nullSafety(Off)
class Shelf extends Model {
	/**
	 * Do not manipulate directly, use put and remove instead
	 */
	@observe public var items(default, null):List<SorcererItem>;

	public function new() {
		super();
		items = new List<SorcererItem>();
	}

	public function put(item:SorcererItem):Bool {
		if (items.length >= Data.configs.get(ShelfSize).sure().value) 
			return false;
		trace("put item on shelf");
		items.add(item);
		this.invalidateItems();
		return true;
	}

	public function putOnHiddenTemporarySlot(item:SorcererItem):Void {
		items.add(item);
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
