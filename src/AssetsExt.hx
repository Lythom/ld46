import ceramic.Path;
import ceramic.Assets;

class AssetsExt {
	static public function textureFromFile(assets:Assets, filePath:String) {
		return assets.texture('image:${Path.withoutExtension(filePath)}');
	}
}
