extends State
class_name PlayerBallAiming

@export var player : Player
@export var animation_tree : AnimationTree
@export var direction : Direction

var club_node = preload("res://Scenes/club.tscn")
var club : Club

var aim_line : Sprite2D

func OnEnter():
	animation_tree["parameters/conditions/swing"] = true
	club = club_node.instantiate()
	player.add_child(club)
	direction.set_rotational()
	direction.direction = (player.ball_in_range.global_position - player.position).normalized()
	aim_line = player.ball_in_range.get_node("AimLine")
	aim_line.modulate = Color(1,1,1,1)
	pass

func OnExit():
	aim_line.scale = Vector2(0, 0)
	aim_line.modulate = Color(1,1,1,0)
	aim_line = null
	pass

func Update(_delta : float):
	var y = - direction.value().y;
	club.z_index = 1 if y < 0 else -1
	animation_tree["parameters/Swing/blend_position"] = y

	var axis_input = Input.get_axis("down", "up")
	var fine = Input.is_action_pressed("fine")

	var charge_delta = 0.1 * axis_input if fine else axis_input
	club.update_charge(charge_delta, - direction.value().x)

	aim_line.scale = Vector2(club.get_charge_percent(), 1)
	aim_line.rotation = direction.value().normalized().angle()

	if Input.is_action_just_pressed("swing"):
		Transitioned.emit(self, "PlayerSwinging")
		return

func Physics_Update(_delta : float):
	var rotation = - direction.value().normalized()
	var distance = 10
	var offset = Vector2(0, -6)

	if not player.ball_in_range:
		Transitioned.emit(self, "PlayerIdle")

	var point_to_aim_from = player.ball_in_range.global_position + distance * rotation + offset
	var distance_to_point = point_to_aim_from - player.global_position
	player.velocity = player.velocity.lerp(distance_to_point * 8, 1)

	pass

