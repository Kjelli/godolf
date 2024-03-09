extends Label

func _ready():
	modulate = Color(1,1,1,0)
	Events.connect(Events.ball_sunk.get_name(), announce_shot_score)

func announce_shot_score(ball : Ball) -> void:
	var score : Golf.Score = Golf.get_score(ball.times_hit, Golf.current_course_par)
	text = score.name

	modulate = Color(1,1,0,0) if score.value < 0 else Color(0,1,0,0) if score.value == 0 else Color(1,0,0,0)

	await get_tree().create_tween().tween_property(self, "modulate:a", 1.0, 1.0).finished
	await get_tree().create_timer(2).timeout
	await get_tree().create_tween().tween_property(self, "modulate:a", 0.0, 1.0).finished
