package ld46.model;

import tracker.Model;

class Player extends Model {
	var playerName:String;
	var sorcerers:List<Sorcerer>;
	var battles:List<Battle>;

	public function new(playerName:String) {
		super();
		this.playerName = playerName;
		battles = new List<Battle>();
		sorcerers = new List<Sorcerer>();
		sorcerers.add(new Sorcerer());
		sorcerers.add(new Sorcerer());
		sorcerers.add(new Sorcerer());
	}
}
