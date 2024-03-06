extends State

@export var ball : Ball

func OnEnter():
	ball.acceleration = Vector2.ZERO
	var sinkTween = get_tree().create_tween()
	sinkTween.set_ease(Tween.EASE_IN)
	sinkTween.tween_property(ball, "position", ball.is_in_goal.position, 0.2)
	sinkTween.tween_property(ball, "modulate", Color(0,0,0,0), 0.5)
	await sinkTween.finished

	onSunk()
	pass

func OnExit():
	pass

func onSunk():
	Events.ball_sunk.emit(ball)
	print("Nice! Sunk on shot #" + str(ball.times_hit))
	ball.call_deferred("queue_free")

func Physics_Update(_delta : float):
	ball.velocity = (ball.is_in_goal.position - ball.position).normalized() * 10
