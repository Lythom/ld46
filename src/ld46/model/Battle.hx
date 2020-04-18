package ld46.model;

import tracker.Model;

class Battle extends Model {
	var playerA:Player;
    var playerB:Player;
    
    var winner:Player = null;

	public function new() {
		super();
	}
}
