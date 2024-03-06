extends State
class_name NoBallNear

@export var goal : Goal

func OnEnter():
	pass

func OnExit():
	pass

func Update(_delta : float):
	if goal.nearby_balls.size():
		Transitioned.emit(self, "BallNear")
	
func Physics_Update(_delta : float):
	pass
