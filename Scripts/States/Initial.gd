extends PlayerState

func OnEnter():
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer || player.player_id == multiplayer.get_unique_id():
		Local.print("Player " + str(player.player_id) + " is now real")
		state_machine.transitioned.emit(self, "Idle")
	else:
		Local.print("Player " + str(player.player_id) + " is now fake")
		state_machine.transitioned.emit(self, "Fake")

func OnExit():
	pass

func Process(_delta : float):
	pass

func Physics_Process(_delta : float):
	pass
