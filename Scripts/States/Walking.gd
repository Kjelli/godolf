extends PlayerState

func OnEnter():
	player.animation_tree["parameters/conditions/is_moving"] = true
	pass

func OnExit():
	player.animation_tree["parameters/conditions/is_moving"] = false
	pass

func Process(_delta : float):
	if player.velocity.length_squared() < 20:
		state_machine.transitioned.emit(self, "idle")
		return

	if player.can_swing() && player.player_input.pressed_swing():
		state_machine.transitioned.emit(self, "aiming")
		return

	if player.player_input.direction != Vector2.ZERO:
		player.animation_tree["parameters/Idle/blend_position"] = player.player_input.direction
		player.animation_tree["parameters/Walk/blend_position"] = player.player_input.direction

	player.sync_direction = player.player_input.direction

func Physics_Process(_delta : float):
	if player.player_input.direction == Vector2.ZERO:
		player.velocity = player.velocity.lerp(Vector2.ZERO, 0.8)
	else:
		player.velocity = player.velocity.lerp(player.player_input.direction * player.move_speed, 0.5)

	player.move_and_slide()

	player.sync_pos = player.position

