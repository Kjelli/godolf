extends PlayerState

func OnEnter():
	player.animation_tree["parameters/conditions/idle"] = true
	pass

func OnExit():
	player.animation_tree["parameters/conditions/idle"] = false
	pass

func Process(_delta : float) -> void:
	if player.player_input.direction != Vector2.ZERO:
		state_machine.transitioned.emit(self, "walking")
		return

	if player.can_swing() && player.player_input.pressed_swing():
		state_machine.transitioned.emit(self, "aiming")
		return

	player.sync_direction = player.player_input.direction

func Physics_Process(_delta : float) -> void:
	player.sync_pos = player.position
	pass
