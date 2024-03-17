extends BallState

var current_trail : Trail

func OnEnter():
	pass

func OnExit():
	pass

func Process(_delta : float):
	if !ball.is_moving && ball.sync_is_moving:
		current_trail = Trail.create()
		ball.add_child(current_trail)
	elif ball.is_moving && !ball.sync_is_moving:
		current_trail.stop()
		current_trail = null
	set_properties_from_synced()

func Physics_Process(_delta : float):
	pass
