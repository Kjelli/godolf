extends State

@export var ball : Ball
@export var pulser : Pulser

func Update(_delta : float):
	if ball.velocity != Vector2.ZERO:
		Transitioned.emit(self, "BallMoving")

func OnEnter():
	pulser.enable()
	pass

func OnExit():
	pulser.disable()
	pass
