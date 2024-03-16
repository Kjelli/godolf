extends State
class_name NoBallNear

@export var goal : Goal

func OnEnter():
	pass

func OnExit():
	pass

func Process(_delta : float):
	if goal.nearby_balls.size():
		state_machine.transitioned.emit(self, "BallNear")
