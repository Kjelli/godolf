extends State

@export var ball : Ball
@export var ballSprite : Sprite2D
@export var particles : GPUParticles2D

func Update(_delta : float):
	pass

func OnEnter():
	particles.emitting = true
	ball.velocity = Vector2.ZERO
	ball.acceleration = Vector2.ZERO
	ballSprite.modulate.a = 0
	await get_tree().create_timer(1).timeout

	ballSprite.modulate.a = 1
	ball.global_position = ball.last_shot_from
	Transitioned.emit(self, "BallIdle")
	pass
