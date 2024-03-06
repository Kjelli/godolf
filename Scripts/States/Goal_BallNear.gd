extends State
class_name BallNear

@export var goal : Goal
@export var flag : Sprite2D

func OnEnter():
	get_tree().create_tween().tween_property(flag, "modulate", Color(1, 1, 1, 0), 1)
	get_tree().create_tween().tween_property(flag, "offset", Vector2(0, -50), 1)
	pass

func OnExit():
	get_tree().create_tween().tween_property(flag, "modulate", Color(1, 1, 1, 1), 1)
	get_tree().create_tween().tween_property(flag, "offset", Vector2(0, 0), 1)
	pass

func Update(_delta : float):
	if !goal.nearby_balls.size():
		Transitioned.emit(self, "NoBallNear")
	
func Physics_Update(_delta : float):
	pass
