package ld46.model;

import tracker.Model;

class Battle extends Model {
	public var playerA:Player;
    public var playerB:Player;
    
    public var winner:Null<Player> = null;

	public function new(playerA:Player,playerB:Player) {
		super();
		this.playerA = playerA;
		this.playerB = playerB;
	}
}
