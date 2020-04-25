class NullTools {
	public static function sure<T>(value:Null<T>):T {
		if (value == null) {
			throw "null pointer in .sure() call";
		}
		return @:nullSafety(Off) (value : T);
	}

	public static function or<T>(value:Null<T>, defaultValue:T):T {
		if (value == null) {
			return defaultValue;
		}
		return @:nullSafety(Off) (value : T);
	}

	static public inline function run<T>(value:Null<T>, callback:T->Void):Void {
		if (value != null)
			callback(@:nullSafety(Off) (value : T));
	}
}
