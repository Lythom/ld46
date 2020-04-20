Le joueur lance le jeu
- écran d'accueil, bouton "jouer"
- écran de jeu
	- Phase ShopEquip
		- init phase
			- [server] init deck, AI opponent data, battle list
			- display plateau simple
			- reset 3 sorcerers and Chaleace positions to player configuration
			- display SorcererUI on characters and chaleace (HP, stats on hover)
			- display Shop
			- display Shelf
			- display Trash,
			- display Bouton "Next Round"
			- [server] draw items out of deck to shops (5 by player)
			- [server] credit shop based on last fight (loss=2, win=3, initial=3)
			- [server] play AI turn (shop, equip)
		- les personnages sont déjà équipés d'items de départ au début de partie
		- un shop avec 5 items tirés au hasard dans le deck sont présentés, 3 peuvent être sélectionnés (crédit round 3). les items dans le shop ne sont plus dans le deck.
		- Click sur un items emmène directement l'item sur le shelf.
		- Si le shelf est plein un click 
			- ajoute temporaire l'item sur un slot caché
			- déclenche une tentative du fusion
			- si pas de fusion possible, affiche le message "Shelf is full, remove some item to get this one"
		- tentative de fusion :
			- Pour chaque sorcerer
				- Si le shelf + slots d'équipement contiennent 3 items identiques, ils fusionnent pour obtenir un niveau supérieur
				- si un des items est sur le slot d'équipement, c'est celui là qui level up.
		- survol d'un item affiche la description complète dans une bulle (shelf, shop, equipped)
		- Drag and drop item sur Trash détruit l'item définitivement
		- Drag and drop item sur Personnage remplace avec l'item équipe sur le slot équivalent. Vise le personnage le plus proche dans la dropZone (< 200 px du personnage).
		- Drag and drop personnage sur le terrain change sa position initiale. Dans les limites du terrain.

		- Click sur bouton "Next Round" déclenche la phase Combat
			- hide shop
			- hide next round button
			- hide shelf
			- hide trash
	- Phase Battle
		- init phase
			- [server] put shops back in the deck and shuffle
			- [server] affect players into random battles
			- [server] init battle data
				- health point to max
				- clear buff bonus list
				- inverse playerB position
			- display plateau double with opponent sorcerers and chaleace

		- [server] update
			- For each battle 
				- for each chaleace
					- lock damage after 7 seconds
					- display charging bar
				- For each sorcerer
					- change target
						- if sorcerer is saboteur, target closest standing opponent Chaleace / saboteur / duelist / protector
						- if sorcerer is duelist, target closest standing opponent duelist / saboteur / protector / Chaleace
						- if sorcerer is Protector, target closest standing opponent saboteur / duelist / protector / Chaleace

					- move closer, dodge going right
					- try attack
						- if attackcooldown is 0 attack and set attackcooldown to "1 / attackSpeed"
						- if attackcooldown > 0 attackcooldown-= deltaTime
						- attack 
							- damage the opponent (damage = ally.attackDamage * (100 / (100 + opponent.Defense)))
							- trigger onHit effects
							- if opponent.hp <= 0 opponent fall on the ground 
							- if opponent.hp > 0 trigger opponent onDamaged effets
		
		- [server] a chaleace has no more HP, do Game Over
		- [server] a team is entierly down, do End battle
		- [server] no other opponent have a chaleace with hp > 0, do Game Over
			- End battle:
				- Display victory or Lose
				- Display number of Chaleace health lost
				- wait other battles
				- transition to ShopEquip phase
			- Game Over:
				- Display "Game Over" or "Congratulations" in no other opponent have a chaleace with hp > 0
				- Display "continue" button that open main menu screen.
			


Le deck contient 32 occurrence de chaque item.

Le Shelf contient 12 emplacements (configurable).


top board offset (+398, -168)