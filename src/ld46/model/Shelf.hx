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
		items.add(item);
		this.dirty = true;
		return true;
	}

	public function remove(item:SorcererItem):Bool {
		var res = items.remove(item);
		this.dirty = true;
		return res;
	}
}
