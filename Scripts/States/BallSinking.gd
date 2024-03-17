extends BallState

func OnEnter():
	ball.is_in_goal = ball.nearby_goal
	if ball.times_hit < CourseContext.current_hole_descriptor.hole_par:
		ball.is_in_goal.emit_particles()

	ball.acceleration = Vector2.ZERO

	var sinkTween = get_tree().create_tween()
	sinkTween.set_ease(Tween.EASE_IN)
	sinkTween.tween_property(ball, "position", ball.is_in_goal.position, 0.2)
	sinkTween.tween_property(ball, "modulate", Color(0,0,0,0), 0.5)
	sinkTween.tween_callback(ball.trigger_sink)

func OnExit():
	pass

func Process(_delta : float):
	sync_properties()
	pass

func Physics_Process(_delta : float):
	ball.velocity = (ball.is_in_goal.position - ball.position).normalized() * 10
	pass

