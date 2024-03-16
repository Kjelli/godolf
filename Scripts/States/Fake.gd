extends PlayerState

func OnEnter():
	Local.print("Player " + str(player.player_id) + " is now fake")
	pass

func OnExit():
	pass

func Process(_delta : float):
	if player.sync_direction != Vector2.ZERO:
			player.animation_tree["parameters/Idle/blend_position"] = player.sync_direction
			player.animation_tree["parameters/Walk/blend_position"] = player.sync_direction

	player.animation_tree["parameters/conditions/swing"] = player.sync_is_swinging
	player.animation_tree["parameters/conditions/idle"] = !player.sync_is_swinging && player.sync_direction == Vector2.ZERO
	player.animation_tree["parameters/conditions/is_moving"] = !player.sync_is_swinging && player.sync_direction != Vector2.ZERO

	var y = - player.sync_direction.y;
	player.club.z_index = 1 if y < 0 else -1
	player.animation_tree["parameters/Swing/blend_position"] = y

	player.club.visible = player.sync_club_vis
	Local.tween(player.club, "rotation", player.sync_club_rot, 0.1)

	get_tree().create_tween().tween_property(player, "position", player.sync_pos, 0.05)

func Physics_Process(_delta : float):
	pass

