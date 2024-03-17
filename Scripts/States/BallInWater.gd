extends BallState

func OnEnter():
	ball.splash_particles.emitting = true
	ball.velocity = Vector2.ZERO
	ball.acceleration = Vector2.ZERO
	ball.sprite.modulate.a = 0
	await get_tree().create_timer(1).timeout

	ball.sprite.modulate.a = 1
	ball.global_position = ball.last_shot_from
	Events.ball_stopped.emit(ball)
	state_machine.transitioned.emit(self, "idle")

func OnExit():
	pass

func Process(_delta : float):
	sync_properties()
	pass

func Physics_Process(_delta : float):
	pass

