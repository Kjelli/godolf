extends CanvasGroup

@onready var title : Label = $AnnouncementLabel
@onready var line : Line2D = $Line2D
@onready var title_position : Vector2 = title.position

var time_alive = 0
func _ready():
	Events.connect(Events.ball_sunk.get_name(), announce_shot_score)

func _process(delta: float) -> void:
	time_alive += delta
	title.position.y = title_position.y + 3 * sin(time_alive * 2)
	scale = Vector2(0.975 + 0.025 * scale.x * sin(time_alive * 1.5) * sin(time_alive * 6), 0.975 + 0.025 * scale.y * cos(time_alive * 6) * cos(time_alive * 1.5))

func announce_shot_score(ball : Ball) -> void:
	var score : Golf.Score = Golf.get_score(ball.times_hit, Golf.current_course_par)
	title.text = score.name

	modulate = Color(1,1,0,0) if score.value < 0 else Color(0,1,0,0) if score.value == 0 else Color(1,1,1,0)

	var title_pos = title.get_rect().position
	var title_size = title.get_rect().size
	var title_center = title_pos + title_size / 2
	var title_font_size = title.get_theme_default_font_size()
	var line_width = (title.text.length() + 1) * title_font_size

	line.clear_points()
	line.add_point(Vector2(title_center.x - line_width / 2, title_pos.y + title_size.y - title_font_size))
	line.add_point(Vector2(title_center.x, title_pos.y + title_size.y - title_font_size))
	line.add_point(Vector2(title_center.x + line_width / 2, title_pos.y + title_size.y - title_font_size))

	await get_tree().create_tween().tween_property(self, "modulate:a", 1.0, 1.0).finished
	await get_tree().create_timer(2).timeout
	await get_tree().create_tween().tween_property(self, "modulate:a", 0.0, 1.0).finished
