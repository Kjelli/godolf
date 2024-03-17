class_name BallState
extends State

var ball : Ball

func _ready() -> void:
	await owner.ready
	ball = owner as Ball
	assert(ball != null)

func sync_properties():
	ball.sync_aim_vis = ball.aim_line.visible
	ball.sync_splash_emit = ball.splash_particles.emitting
	ball.sync_mod_a = ball.sprite.modulate.a
	ball.sync_scale = ball.scale
	ball.sync_aim_scale = ball.aim_line.scale
	ball.sync_aim_rot = ball.aim_line.rotation
	ball.sync_pos = ball.position
	ball.sync_is_moving = ball.is_moving

func set_properties_from_synced():
	ball.aim_line.visible = ball.sync_aim_vis
	ball.splash_particles.emitting = ball.sync_splash_emit
	Local.tween(ball.sprite, "modulate:a", ball.sync_mod_a, 0.1)
	Local.tween(ball, "scale", ball.sync_scale, 0.1)
	Local.tween(ball.aim_line, "scale", ball.sync_aim_scale, 0.1)
	Local.tween(ball.aim_line, "rotation", ball.aim_line.rotation + wrapf(ball.sync_aim_rot - ball.aim_line.rotation, -PI, PI), 0.1)
	Local.tween(ball, "position", ball.sync_pos, 0.05)
	ball.is_moving = ball.sync_is_moving

