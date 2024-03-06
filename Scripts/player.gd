extends CharacterBody2D
class_name Player

var ball_in_range : Ball
var player_id : String

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	move_and_slide()

func set_id(id : String):
	player_id = id

func can_swing():
	if ball_in_range:
		if ball_in_range.state_machine.current_state.name == "BallIdle":
			return true
	return false

func _on_ball_range_body_entered(body):
	if body is Ball:
		ball_in_range = body


func _on_ball_range_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is Ball:
		if body == ball_in_range:
			ball_in_range = null

