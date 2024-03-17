extends BallState

var current_trail : Trail

func OnEnter():
	ball.pulser.enable()
	Events.ball_stopped.emit(ball)
	ball.velocity = Vector2.ZERO
	ball.acceleration = Vector2.ZERO
	ball.is_moving = false
	if current_trail:
		current_trail.stop()
		current_trail = null

func OnExit():
	ball.pulser.disable()
	current_trail = Trail.create()
	ball.add_child(current_trail)
	ball.is_moving = true

func Process(_delta : float):
	sync_properties()

	if ball.velocity != Vector2.ZERO:
		state_machine.transitioned.emit(self, "rolling")
		return

func Physics_Process(_delta : float):
	pass
