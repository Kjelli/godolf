extends PlayerState

var is_swinging : bool

func OnEnter():
	player.animation_tree["parameters/conditions/swing"] = true
	player.velocity = Vector2.ZERO
	player.player_input.set_direction_rotational()
	player.player_input.direction = player.player_input.direction.normalized()
	player.club.show()
	player.sync_is_swinging = true
	Events.local_player_swinging.emit()
	pass

func OnExit():
	is_swinging = false

	player.player_input.set_direction_eight_directional()
	player.club.hide()
	player.animation_tree["parameters/conditions/swing"] = false

	player.sync_is_swinging = false
	player.sync_club_vis = player.club.visible
	player.sync_direction = player.player_input.direction
	pass

func Process(_delta : float):
	player.sync_club_rot = player.club.rotation
	player.sync_club_vis = player.club.visible
	player.sync_direction = player.player_input.direction

	if is_swinging:
		return

	var y = - player.player_input.direction.y;
	player.club.z_index = 1 if y < 0 else -1
	player.animation_tree["parameters/Swing/blend_position"] = y

	var axis_input = Input.get_axis("down", "up")
	var fine = Input.is_action_pressed("fine")

	var charge_delta = 0.05 * axis_input if fine else axis_input
	player.club.update_charge(player.player_id, charge_delta, - player.player_input.direction.x)
	player.ball_in_range.aim(player.club.charge, player.club.max_charge, player.player_input.direction)

	# If some cheeky ball movement occurs, cancel aiming and reset
	if player.ball_in_range.velocity != Vector2.ZERO:
		player.club.interrupted(player.player_id)
		player.ball_in_range.aim_line.hide()
		state_machine.transitioned.emit(self, "idle")

	if player.player_input.pressed_swing() && !is_swinging:
		is_swinging = true
		var leftSwing = PI * player.club.charge / player.club.max_charge
		var rightSwing = - PI * player.club.charge / player.club.max_charge

		var afterSwing = leftSwing if player.player_input.direction.x < 0 else rightSwing

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(player.club, "rotation", 0, 0.05)
		tween.connect("finished", on_swing)

		var after_tween = get_tree().create_tween()
		after_tween.tween_property(player.club, "rotation", afterSwing, 0.2)
		after_tween.tween_property(player.club, "rotation", 0, 0.1)
		after_tween.connect("finished", on_after_swing)


func on_swing():
	if player.ball_in_range:
		player.ball_in_range.hit(player.club.charge, player.player_input.direction)

func on_after_swing():
	state_machine.transitioned.emit(self, "idle")

func Physics_Process(_delta : float):
	if is_swinging:
		return

	var target_rotation = - player.player_input.direction.normalized()
	var distance = 10
	var offset = Vector2(0, -6)

	if not player.ball_in_range:
		player.club.interrupted(player.player_id)
		player.ball_in_range.aim_line.hide()
		state_machine.transitioned.emit(self, "idle")

	var pivot_point = player.ball_in_range.global_position
	var point_to_aim_from = pivot_point + distance * target_rotation + offset
	var distance_to_point = point_to_aim_from - player.global_position
	player.velocity = player.velocity.lerp(distance_to_point * 8, 1)

	player.move_and_slide()

	player.sync_pos = player.position
