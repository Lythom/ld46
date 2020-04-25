package ld46;

import ld46.model.BoardEntity;
import lythom.stuffme.AttributeValues;

class LD46Utils {
	// from https://github.com/jasononeil/hxrandom/blob/master/src/Random.hx

	/** Return a random integer between 'from' and 'to', inclusive. */
	public static inline function randomInt(from:Int, to:Int):Int {
		return from + Math.floor(((to - from + 1) * Math.random()));
	}

	public static inline function pickRandom<T>(array:Array<T>):Null<T> {
		return array[randomInt(0, array.length - 1)];
	}

	public static inline function first<T>(array:Array<T>):Null<T> {
		return array.length > 0 ? array[0] : null;
	}

	public static inline function clear<T>(array:Array<T>) {
		return array.splice(0, array.length);
	}

	public static inline function last<T>(array:Array<T>):Null<T> {
		return array.length > 0 ? array[array.length - 1] : null;
	}

	/** Return a random string of a certain length.  You can optionally specify 
		which characters to use, otherwise the default is (a-zA-Z0-9) */
	public static function randomString(length:Int, charactersToUse = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String {
		var str = "";
		for (i in 0...length) {
			str += charactersToUse.charAt(LD46Utils.randomInt(0, charactersToUse.length - 1));
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

	public static function getValue(attributeValues:AttributeValues, stat:Data.StatsKind, defaultValue:Float = 0):Float {
		return attributeValues.get(stat.sure().toString()).or(defaultValue);
	}

	public static function setValue(attributeValues:AttributeValues, stat:Data.StatsKind, value:Float) {
		return attributeValues.set(stat.sure().toString(), value);
	}

	public static function distanceWith(entity:BoardEntity, target:BoardEntity):Float {
		return distance(entity.x, entity.y, target.x, target.y);
	}

	public static function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		var a = x2 - x1;
		var b = y2 - y1;
		return Math.sqrt(a * a + b * b);
	}

	public static function angleInRad(x1:Float, y1:Float, x2:Float, y2:Float):Float {
		var a = x2 - x1;
		var b = y2 - y1;
		return Math.atan2(b, a);
	}

	public static function getAttributeDescription(attrValues:AttributeValues):String {
		return Data.stats.all.map(stat -> getAttributeValueDescription(attrValues, stat.id)).filter(str -> str != null).join('\n');
	}

	public static function getAttributeValueDescription(attrValues:AttributeValues, stat:Data.StatsKind):Null<String> {
		var value = attrValues.getValue(stat);
		if (value == 0)
			return null;
		switch (stat) {
			case AttackSpeed:
				return 'Attack Speed: +' + Std.int(value) + ' Atk/sec';
			default:
				return stat.toString() + ': +' + Std.int(value);
		}
	}
}
