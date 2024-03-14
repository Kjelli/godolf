extends Node
class_name PlayerScore

var player_id : int
var player_name : String
var player_color : Color
var scores : PackedInt32Array = []

static func create(_player_id : int, _player_name : String, _player_color : Color, _course_info : CourseDescriptor) -> PlayerScore:
	var player_score = new()
	player_score.player_id = _player_id
	player_score.player_name = _player_name
	player_score.player_color = _player_color
	player_score.scores = []
	for _i in range(_course_info.holes.size()):
		player_score.scores.append(0)
	return player_score

func sum() -> int:
	var _sum = 0
	for score in scores:
		_sum += score
	return _sum
