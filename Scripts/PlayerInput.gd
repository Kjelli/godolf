extends Node
class_name PlayerInput

enum DirectionMode { Ignore, EightDirections, Rotation }

@export var direction_mode : DirectionMode

@export var initial_direction_mode : DirectionMode
@export var direction := Vector2()

func _ready():
	if initial_direction_mode:
		direction_mode = initial_direction_mode

func has_zero_direction():
	return direction == Vector2.ZERO

func set_direction_rotational():
	direction = Vector2(0, 1)
	direction_mode = DirectionMode.Rotation

func set_direction_eight_directional():
	direction_mode = DirectionMode.EightDirections

func pressed_swing() -> bool:
	return get_multiplayer_authority() == multiplayer.get_unique_id() && Input.is_action_just_pressed("swing")

func _process(_delta):
	if direction_mode == DirectionMode.EightDirections:
		direction = Input.get_vector("left", "right", "up", "down").normalized()
	elif direction_mode == DirectionMode.Rotation:
		var input = Input.get_axis("left", "right")
		input = 0.25 * input if Input.is_action_pressed("fine") else input
		direction = direction.rotated(input / 50)
	pass
