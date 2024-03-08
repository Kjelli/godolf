extends Control

@onready var shots : Label = $CountLabel

var time_alive = 0

func _ready():
	Events.connect(Events.ball_shot.get_name(), update_count)
	Events.connect(Events.ball_sunk.get_name(), lock_count)

func _process(delta: float) -> void:
	time_alive += delta
	position.y = position.y + 0.025 * cos(time_alive * 2)
	scale = Vector2(0.975 + 0.025 * scale.x * sin(time_alive * 1.5) * sin(time_alive * 6), 0.975 + 0.025 * scale.y * cos(time_alive * 6) * cos(time_alive * 1.5))

func update_count(ball : Ball):
	shots.text = str(ball.times_hit)

func lock_count(ball : Ball):
	shots.modulate = Color(0, 1, 0, 1)
