package;

class HotLoader extends ceramic.Entity {

    public static var instance:HotLoader;

    @event function reload();

    public function new(loadObservableAsset:Void->Void) {
        super();
        // autorun(loadObservableAsset, this.emitReload);
        instance = this;
    }

}