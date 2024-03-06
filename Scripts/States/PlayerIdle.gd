extends State
class_name PlayerIdle

@export var player : Player
@export var animation_tree : AnimationTree
@export var direction : Direction

func OnEnter():
	animation_tree["parameters/conditions/idle"] = true
	pass

func OnExit():
	animation_tree["parameters/conditions/idle"] = false
	pass

func Update(_delta : float):
	if !direction.is_zero():
		Transitioned.emit(self, "playerwalking")
		return
	
	if player.can_swing() && Input.is_action_just_pressed("swing"):
		Transitioned.emit(self, "playerballaiming")
		return
	
	pass
	
func Physics_Update(_delta : float):
	player.velocity = player.velocity.lerp(Vector2.ZERO, 0.8)
	pass

