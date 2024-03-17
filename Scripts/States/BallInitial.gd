extends BallState

func OnEnter():
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer || ball.player_id == multiplayer.get_unique_id():
		state_machine.transitioned.emit(self, "Idle")
	else:
		state_machine.transitioned.emit(self, "Fake")

func OnExit():
	pass

func Process(_delta : float):
	pass

func Physics_Process(_delta : float):
	pass

