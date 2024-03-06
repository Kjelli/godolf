extends Node
class_name Direction

enum DirectionMode { Ignore, EightDirections, Rotation }

@onready var direction : Vector2 = Vector2.ZERO
@onready var mode

@export var initialMode : DirectionMode

func _ready():
	if initialMode:
		mode = initialMode

func value():
	return direction
	
func is_zero():
	return direction == Vector2.ZERO
	
func set_rotational():
	direction = Vector2(0, 1)
	mode = DirectionMode.Rotation
	
func set_eight_directional():
	mode = DirectionMode.EightDirections

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mode == DirectionMode.EightDirections:
		direction = Input.get_vector("left", "right", "up", "down").normalized()
	elif mode == DirectionMode.Rotation:
		var input = Input.get_axis("left", "right")
		input = 0.25 * input if Input.is_action_pressed("fine") else input
		direction = direction.rotated(input / 50)
	pass
