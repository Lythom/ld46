package ld46.model;

import tracker.Model;

@:nullSafety(Off)
class Battle extends Model {
	public static var ID:Int = 0;

	public var playerA:Player;
	public var playerB:Player;
	public var idBattle:Int;

	@observe public var winner:Null<Player> = null;

	public var cumulatedTime:Float;

	public function new(playerA:Player, playerB:Player) {
		super();
		idBattle = ID++;
		cumulatedTime = 0;
		this.playerA = playerA;
		this.playerB = playerB;
		if (this.playerA == null)
			throw 'playerA required';

		app.onceUpdate(this, delta -> {
			if (playerB != null) {
				// init player board
				playerA.resetEntities();
				playerB.resetEntities();
				playerB.moveToPlayerB();

				for (s in this.playerA.sorcerers)
					s.onAttackTarget(this, handleAttack);
				for (s in playerB.sorcerers)
					s.onAttackTarget(this, handleAttack);
			} else {
				winner = this.playerA;
				this.playerA.gameState = BattleEnded;
				endBattle();
			}
		});
	}

	public function handleAttack(from:BoardEntity, target:BoardEntity, attack:Float):Void {
		var attack = from.calculatedStats.getValue(AttackDamage);
		var power = from.calculatedStats.getValue(Power);
		var targetDef = target.calculatedStats.getValue(Defense);
		var damage = attack - attack * targetDef / (100 + targetDef) + power;
		target.takeDamage(from, damage);
	}

	public function checkEndConditions() {
		if (playerA.chaleace.health <= 0) {
			winner = playerB;
			endBattle();
			playerA.gameState = OutOfTournament;
			playerB.gameState = BattleEnded;
			trace("Elminated :" + playerA.playerName);
			trace("Winner :" + playerB.playerName);
		}
		if (playerB.chaleace.health <= 0) {
			winner = playerA;
			endBattle();
			playerA.gameState = BattleEnded;
			playerB.gameState = OutOfTournament;
			trace("Elminated :" + playerB.playerName);
			trace("Winner :" + playerA.playerName);
		}
		if (playerA.sorcerers.foreach(s -> s.health <= 0) && playerA.chaleace.lockIn <= 0) {
			winner = playerB;
			endBattle();
			playerA.gameState = BattleEnded;
			playerB.gameState = BattleEnded;
			trace("Winner :" + playerB.playerName);
		}
		if (playerB.sorcerers.foreach(s -> s.health <= 0) && playerB.chaleace.lockIn <= 0) {
			winner = playerA;
			endBattle();
			playerA.gameState = BattleEnded;
			playerB.gameState = BattleEnded;
			trace("Winner :" + playerA.playerName);
		}
	}

	public function endBattle() {
		for (s in playerA.sorcerers)
			s.offAttackTarget(handleAttack);
		if (playerB != null)
			for (s in playerB.sorcerers)
				s.offAttackTarget(handleAttack);
	}

	public function tick(delta:Float) {
		if (playerB == null || winner != null)
			return;
		cumulatedTime += delta;

		if (playerA.chaleace.lockIn > 0)
			playerA.chaleace.lockIn = Math.max(0, playerA.chaleace.lockIn - delta);
		if (playerB.chaleace.lockIn > 0)
			playerB.chaleace.lockIn = Math.max(0, playerB.chaleace.lockIn - delta);

		for (s in playerA.sorcerers)
			s.targetClosest(playerB.boardEntities);
		for (s in playerB.sorcerers)
			s.targetClosest(playerA.boardEntities);

		for (s in playerA.sorcerers)
			s.moveAttack(delta);
		for (s in playerB.sorcerers)
			s.moveAttack(delta);

		for (s in playerA.sorcerers)
			s.moveAttack(delta);
		for (s in playerB.sorcerers)
			s.moveAttack(delta);

		checkEndConditions();
	}
}
