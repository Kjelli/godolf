extends State
class_name PlayerWalking

@export var player : Player
@export var animation_tree : AnimationTree
@export var direction : Direction
@export var move_speed := 50

func OnEnter():
	animation_tree["parameters/conditions/is_moving"] = true

func OnExit():
	animation_tree["parameters/conditions/is_moving"] = false

func Update(_delta : float):
	if direction.is_zero():
		Transitioned.emit(self, "playeridle")
		return
	
	if !direction.is_zero():
		animation_tree["parameters/Idle/blend_position"] = direction.value()
		animation_tree["parameters/Walk/blend_position"] = direction.value()
	
	if player.can_swing() && Input.is_action_just_pressed("swing"):
		Transitioned.emit(self, "PlayerBallAiming")
		return
	
func Physics_Update(_delta : float):
	player.velocity = player.velocity.lerp(direction.direction * move_speed, 0.5)
	pass

