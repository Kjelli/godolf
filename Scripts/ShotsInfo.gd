extends Control

@onready var shots : Label = $CountLabel

func _ready():
	Events.connect(Events.ball_shot.get_name(), update_count)
	Events.connect(Events.ball_sunk.get_name(), lock_count)

func update_count(ball : Ball):
	if ball.is_local_authority():
		shots.text = str(ball.times_hit)

func lock_count(ball : Ball):
	if ball.is_local_authority():
		shots.modulate = Color(0, 1, 0, 1)
