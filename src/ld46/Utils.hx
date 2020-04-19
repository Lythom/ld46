package ld46;

class Utils {
	// from https://github.com/jasononeil/hxrandom/blob/master/src/Random.hx

	/** Return a random integer between 'from' and 'to', inclusive. */
	public static inline function randomInt(from:Int, to:Int):Int {
		return from + Math.floor(((to - from + 1) * Math.random()));
	}

	/** Return a random string of a certain length.  You can optionally specify 
		which characters to use, otherwise the default is (a-zA-Z0-9) */
	public static function randomString(length:Int, charactersToUse = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String {
		var str = "";
		for (i in 0...length) {
			str += charactersToUse.charAt(Utils.randomInt(0, charactersToUse.length - 1));
		}
		return str;
	}

	/** Shuffle an Array.  This operation affects the array in place, and returns that array.
		The shuffle algorithm used is a variation of the [Fisher Yates Shuffle](http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle) */
	public static function shuffle<T>(arr:Array<T>):Array<T> {
		if (arr != null) {
			for (i in 0...arr.length) {
				var j = randomInt(0, arr.length - 1);
				var a = arr[i];
				var b = arr[j];
				arr[i] = b;
				arr[j] = a;
			}
		}
		return arr;
	}
}
