extends State
class_name PlayerBallAiming

@export var player : Player
@export var animation_tree : AnimationTree

@onready var player_input : PlayerInput = %PlayerInput
@onready var club : Club = %Club
@export var pivot_point : Vector2

func OnEnter():

	pass

func OnExit():
	pass

func Update(_delta : float):
	var y = - player_input.direction.y;
	club.z_index = 1 if y < 0 else -1
	animation_tree["parameters/Swing/blend_position"] = y



func Physics_Update(_delta : float):
	var rotation = - player_input.direction.normalized()
	var distance = 10
	var offset = Vector2(0, -6)

	if not player.ball_in_range:
		player.velocity = Vector2.ZERO
		print("ball out of range!")
		Transitioned.emit(self, "PlayerIdle")
		return

	pivot_point = player.ball_in_range.global_position
	var point_to_aim_from = pivot_point + distance * rotation + offset
	var distance_to_point = point_to_aim_from - player.global_position
	player.velocity = player.velocity.lerp(distance_to_point * 8, 1)

	pass

