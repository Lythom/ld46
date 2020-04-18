package ld46;

import ceramic.Assets;
import ceramic.Quad;
import ceramic.Text;
import ceramic.Visual;
import ceramic.Shortcuts.*;

@:nullSafety(Strict)
class Main extends Visual {

    var text:Text;
    var test:Quad;

    var assets:Assets;

    public function new(assets:Assets) {
        super();
        this.assets = assets;
        text = new Text();
        test = new Quad();
		
        HotLoader.instance.onReload(this, loadContent);
        loadContent();

        app.onUpdate(this, update);
    }

    function loadContent() {
        text.content = Data.items.all.map(item -> item.id).join(", ");
        test.texture = assets.texture(Data.items.all[0].image);
    }

    function update(delta:Float) {
        
    }
}