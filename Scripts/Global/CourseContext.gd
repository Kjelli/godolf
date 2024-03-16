extends Node

var player_scores : Array = []
var current_course_descriptor : CourseDescriptor
var current_hole_descriptor : HoleDescriptor
var hole_index : int

# Settings
var use_ball_collision : bool

func _ready() -> void:
	Events.ball_sunk.connect(on_ball_sunk)

@rpc("any_peer", "call_local", "reliable")
func init_course(course_name : String, hole_name : String, settings_use_ball_collision : bool) -> void:
	print("Initializing course ", course_name, " -> ", hole_name)
	var course_descriptor = CourseLoader.get_by_name(course_name)
	if not course_descriptor:
		OS.alert("No course found by name '" + course_name + "'!")
	current_course_descriptor = course_descriptor

	if not hole_name:
		hole_index = 0
	else:
		for i in range(course_descriptor.holes.size()):
			var hole = course_descriptor.holes[i] as HoleDescriptor
			if hole.display_name == hole_name:
				hole_index = i
				break

	use_ball_collision = settings_use_ball_collision
	current_hole_descriptor = course_descriptor.holes[hole_index]

func reset() -> void:
	current_course_descriptor = null
	player_scores.clear()
	hole_index = -1
	pass

func on_ball_sunk(player_id : int, _player_name : String, times_hit : int) -> void:
	var score = CourseContext.get_score_by_player_id(player_id) as PlayerScore
	print("Updating score for ", score.player_name, " from ", score.scores[hole_index], " to ", times_hit)
	score.scores[hole_index] = times_hit
	print(score.scores[hole_index], " should be ", times_hit, "?")
	Events.player_score_updated.emit(score)

	if all_players_have_score_for_hole():
		Events.game_proceeding.emit()

		if multiplayer.is_server():
			var has_next_hole = hole_index + 1 < current_course_descriptor.holes.size()
			if has_next_hole:
				var next_hole = GameDescriptor.create(current_course_descriptor, current_course_descriptor.holes[hole_index + 1], use_ball_collision)
				await Local.timer(5).timeout
				Events.game_start_requested.emit(next_hole)
			else:
				await Local.timer(5).timeout
				Events.game_over.emit()


func all_players_have_score_for_hole() -> bool:
	var expected_scores = player_scores.size()
	var counted_scores = 0
	for player : PlayerScore in player_scores:
		if player.scores[hole_index] > 0:
			counted_scores += 1
	return counted_scores == expected_scores

func set_score(player_score : PlayerScore) -> void:
	player_scores.push_back(player_score)

func get_score_by_player_id(player_id : int) -> PlayerScore:
	for score : PlayerScore in player_scores:
		if score.player_id == player_id:
			return score
	return null

func _exit_tree() -> void:
	Events.ball_sunk.disconnect(on_ball_sunk)
