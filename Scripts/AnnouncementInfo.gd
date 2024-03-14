extends CanvasItem

class BallSunkAnnouncement:
	var player_name : String
	var score_name : String
	var score_color : Color

	static func create(_player_name : String, _score_name : String, _score_color : Color) -> BallSunkAnnouncement:
		var announcement : BallSunkAnnouncement = BallSunkAnnouncement.new()
		announcement.player_name = _player_name
		announcement.score_name = _score_name
		announcement.score_color = _score_color
		return announcement

@onready var player_label : Label = %PlayerLabel
@onready var score_label : Label = %ScoreLabel

@onready var announcements : Array = []
var current_announcement : BallSunkAnnouncement

func _ready():
	modulate = Color(1,1,1,0)
	Events.ball_sunk.connect(announce_shot_score)

func announce_shot_score(player_id : int, player_name : String, times_hit : int) -> void:
	var score : Golf.Score = Golf.get_score(times_hit, CourseContext.current_hole_descriptor.hole_par)
	var player = "You" if player_id == multiplayer.get_unique_id() else player_name
	var score_color = Color(1,1,0) if score.value < 0 else Color(0,1,0) if score.value == 0 else Color(1,0,0)

	announcements.append(BallSunkAnnouncement.create(player, score.name.to_upper(), score_color))

func _process(_delta: float) -> void:
	if not current_announcement && announcements.size() > 0:
		current_announcement = announcements.pop_front() as BallSunkAnnouncement

		player_label.text = "%s got" % current_announcement.player_name
		score_label.text = current_announcement.score_name
		modulate = Color(current_announcement.score_color, 0)

		await get_tree().create_tween().tween_property(self, "modulate:a", 1.0, 0.5).finished
		await get_tree().create_timer(3).timeout
		await get_tree().create_tween().tween_property(self, "modulate:a", 0.0, 0.5).finished
		current_announcement = null
