extends State

@export var ball : Ball

var niceNode = preload("res://Scenes/nice.tscn")

func OnEnter():
	var sinkTween = get_tree().create_tween()
	sinkTween.set_ease(Tween.EASE_IN)
	sinkTween.tween_property(ball, "position", ball.is_in_goal.position, 0.2)
	sinkTween.tween_property(ball, "modulate", Color(0,0,0,0), 0.5)
	await sinkTween.finished
	sinkTween.tween_callback(onSunk)
	pass

func OnExit():
	pass

func onSunk():
	var nice : Nice = niceNode.instantiate()
	nice.initial_position = ball.global_position
	ball.get_parent().add_child(nice)
	ball.call_deferred("queue_free")

func Physics_Update(_delta : float):
	ball.velocity = (ball.is_in_goal.position - ball.position).normalized() * 10
