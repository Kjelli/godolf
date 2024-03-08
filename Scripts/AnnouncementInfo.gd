extends Control

@onready var title : Label = $MarginContainer/AnnouncementLabel

var time_alive = 0
func _ready():
	modulate = Color(1,1,1,0)
	Events.connect(Events.ball_sunk.get_name(), announce_shot_score)

func _process(delta: float) -> void:
	time_alive += delta
	title.position.x = title.position.x + 0.025 * sin(time_alive * 2)
	title.position.y = title.position.y + 0.025 * cos(time_alive * 2)
	title.scale = Vector2(0.995 + 0.005 * title.scale.x * sin(time_alive * 1.5) * sin(time_alive * 6), 0.995 + 0.005 * title.scale.y * cos(time_alive * 6) * cos(time_alive * 1.5))

func announce_shot_score(ball : Ball) -> void:
	var score : Golf.Score = Golf.get_score(ball.times_hit, Golf.current_course_par)
	title.text = score.name

	title.modulate = Color(1,1,0,1) if score.value < 0 else Color(0,1,0,1) if score.value == 0 else Color(1,1,1,1)

	var title_pos = title.get_rect().position
	var title_size = title.get_rect().size
	var title_center = title_pos + title_size / 2
	var title_font_size = title.get_theme_default_font_size()

	await get_tree().create_tween().tween_property(self, "modulate:a", 1.0, 1.0).finished
	await get_tree().create_timer(2).timeout
	await get_tree().create_tween().tween_property(self, "modulate:a", 0.0, 1.0).finished
