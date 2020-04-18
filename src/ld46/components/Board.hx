package ld46.components;

import ceramic.Quad;
import ceramic.Texture;

class Board extends Quad {
	public var simpleBoard:Texture;
	public var doubleBoard:Texture;

	public function new(simple:Texture, double:Texture) {
		super();
		this.doubleBoard = double;
		this.simpleBoard = simple;
		this.showSimple();
	}

	public function showSimple() {
		this.texture = simpleBoard;
	}

	public function showDouble() {
		this.texture = doubleBoard;
	}
}
