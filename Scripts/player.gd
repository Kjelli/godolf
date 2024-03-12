extends CharacterBody2D
class_name Player

var ball_in_range : Ball
var is_aiming : bool
var is_swinging : bool

# locals
@onready var animation_tree : AnimationTree = %AnimationTree
@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var player_input : Node = %PlayerInput
@onready var club : Club = %Club

@export var move_speed := 50

# Set by the authority, synchronized on spawn.
@export var player_id : int:
	set(id):
		player_id = id
		on_player_id_set.call_deferred()
@export var player_name : String
@export var player_color : Color

# syncables
@export var sync_pos : Vector2
@export var sync_club_vis : bool
@export var sync_club_rot : float
@export var sync_anim : String
@export var sync_direction : Vector2
@export var sync_is_swinging : bool

static func create(
	new_player_id : int,
	new_player_name : String,
	new_player_color : Color,
	initial_position : Vector2) -> Player:

	var player : Player = preload("res://Scenes/player.tscn").instantiate()
	player.player_id = new_player_id
	player.player_name = new_player_name
	player.player_color = new_player_color
	player.sync_pos = initial_position
	player.position = initial_position
	player.name = str(new_player_id)
	return player

func on_player_id_set():
	set_multiplayer_authority(player_id, false)
	%PlayerInput.set_multiplayer_authority(player_id)
	$DataSynchronizer.set_multiplayer_authority(player_id)
	%Name.text = str(player_name)
	%Name.modulate = player_color
	Events.player_spawned.emit(self)

func _ready():
	position = sync_pos

func _process(_delta: float) -> void:
	update_animation()
	update_actions()

func update_animation():
	if is_multiplayer_authority():
		update_local_animation()
	else:
		if sync_direction != Vector2.ZERO:
			animation_tree["parameters/Idle/blend_position"] = sync_direction
			animation_tree["parameters/Walk/blend_position"] = sync_direction

		animation_tree["parameters/conditions/swing"] = sync_is_swinging
		animation_tree["parameters/conditions/idle"] = !sync_is_swinging && sync_direction == Vector2.ZERO
		animation_tree["parameters/conditions/is_moving"] = !sync_is_swinging && sync_direction != Vector2.ZERO

		var y = - sync_direction.y;
		club.z_index = 1 if y < 0 else -1
		animation_tree["parameters/Swing/blend_position"] = y

		club.visible = sync_club_vis
		#Local.tween(club, "rotation", sync_club_rot, 0.1) # Works but on hard left angle does full rotation
		Local.tween(club, "rotation", sync_club_rot, 0.1)

func update_local_animation():
	if %PlayerInput.direction != Vector2.ZERO:
		animation_tree["parameters/Idle/blend_position"] = %PlayerInput.direction
		animation_tree["parameters/Walk/blend_position"] = %PlayerInput.direction

	if is_aiming || is_swinging:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = false
		animation_tree["parameters/conditions/swing"] = true

		var y = - player_input.direction.y;
		club.z_index = 1 if y < 0 else -1
		animation_tree["parameters/Swing/blend_position"] = y
		pass
	else:
		animation_tree["parameters/conditions/swing"] = false
		if player_input.direction == Vector2.ZERO:
			animation_tree["parameters/conditions/idle"] = true
			animation_tree["parameters/conditions/is_moving"] = false
		else:
			animation_tree["parameters/conditions/idle"] = false
			animation_tree["parameters/conditions/is_moving"] = true

	sync_is_swinging = is_aiming || is_swinging
	sync_direction = %PlayerInput.direction
	sync_club_rot = club.rotation
	sync_club_vis = club.visible

func update_actions():
	if !is_swinging && !is_aiming && can_swing() && %PlayerInput.pressed_swing():
		is_aiming = true
		velocity = Vector2.ZERO
		player_input.set_direction_rotational()
		player_input.direction = player_input.direction.normalized()
		club.show()
	elif !is_swinging &&  is_aiming && !%PlayerInput.pressed_swing():
		var axis_input = Input.get_axis("down", "up")
		var fine = Input.is_action_pressed("fine")

		var charge_delta = 0.1 * axis_input if fine else axis_input
		club.update_charge(player_id, charge_delta, - player_input.direction.x)
		ball_in_range.aim(club.charge, club.max_charge, player_input.direction)
	elif !is_swinging &&  is_aiming && %PlayerInput.pressed_swing():
		is_aiming = false
		is_swinging = true

		var leftSwing = PI * club.charge / club.max_charge
		var rightSwing = - PI * club.charge / club.max_charge

		var afterSwing = leftSwing if player_input.direction.x < 0 else rightSwing

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(club, "rotation", 0, 0.05)
		tween.tween_callback(on_swing)
		tween.tween_property(club, "rotation", afterSwing, 0.2)
		tween.tween_property(club, "rotation", 0, 0.1)

		tween.tween_callback(on_after_swing)
		pass

func on_swing():
	if ball_in_range:
		ball_in_range.hit(club.charge, player_input.direction)

func on_after_swing():
	is_swinging = false
	club.hide()
	player_input.set_direction_eight_directional()

func _physics_process(_delta):
	# Get the input direction and handle the movement/deceleration.
	if is_multiplayer_authority():
		if is_aiming:
			var target_rotation = - player_input.direction.normalized()
			var distance = 10
			var offset = Vector2(0, -6)

			var pivot_point = ball_in_range.global_position
			var point_to_aim_from = pivot_point + distance * target_rotation + offset
			var distance_to_point = point_to_aim_from - global_position
			velocity = velocity.lerp(distance_to_point * 8, 1)
			pass
		elif is_swinging:
			pass
		else:
			if player_input.direction == Vector2.ZERO:
				velocity = velocity.lerp(Vector2.ZERO, 0.8)
			else:
				velocity = velocity.lerp(player_input.direction * move_speed, 0.5)

		move_and_slide()
		sync_pos = position
	else:
		get_tree().create_tween().tween_property(self, "position", sync_pos, 0.05)

func can_swing():
	if !ball_in_range:
		return false
	if ball_in_range.is_in_water:
		return false
	if ball_in_range.velocity != Vector2.ZERO:
		return false
	if !ball_in_range.is_multiplayer_authority():
		return false
	return true

func _on_ball_range_body_entered(body):
	if body is Ball:
		var ball : Ball = body
		if ball.player_id == player_id:
			ball_in_range = ball


func _on_ball_range_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is Ball:
		var ball : Ball = body
		if ball.player_id == player_id:
			ball_in_range = null

