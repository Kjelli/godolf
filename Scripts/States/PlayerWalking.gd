extends State
class_name PlayerWalking

@export var player : Player
@export var animation_tree : AnimationTree


@onready var player_input : PlayerInput = %PlayerInput

func OnEnter():
	animation_tree["parameters/conditions/is_moving"] = true

func OnExit():
	animation_tree["parameters/conditions/is_moving"] = false

