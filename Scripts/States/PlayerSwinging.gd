extends State
class_name PlayerSwinging

@export var player : Player
@export var animation_tree : AnimationTree
@onready var player_input : PlayerInput = %PlayerInput

var club : Node2D

func OnEnter():
	var leftSwing = PI * club.charge / club.max_charge
	var rightSwing = - PI * club.charge / club.max_charge

	var afterSwing = leftSwing if player_input.direction.x < 0 else rightSwing

	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(club, "rotation", 0, 0.05)
	tween.tween_callback(_on_swing)
	tween.tween_property(club, "rotation", afterSwing, 0.2)
	tween.tween_property(club, "rotation", 0, 0.1)

	tween.tween_callback(_on_after_swing)
	pass

func _on_swing():
	if player.ball_in_range:
		player.ball_in_range.hit(club.charge, player_input.direction)

func _on_after_swing():
	Transitioned.emit(self, "PlayerIdle")

func OnExit():
	club.hide()
	player_input.set_direction_eight_directional()
	animation_tree["parameters/conditions/swing"] = false
	pass

func Update(_delta : float):
	pass

func Physics_Update(_delta : float):
	pass

