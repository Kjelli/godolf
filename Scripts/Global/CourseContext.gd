extends Node

var player_scores : Array = []
var current_course_descriptor : CourseDescriptor
var current_hole_descriptor : HoleDescriptor
var hole_index : int

@rpc("any_peer", "call_local", "reliable")
func init_course(course_name : String, hole_name : String) -> void:
	print("Initializing course " + course_name)
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

	current_hole_descriptor = course_descriptor.holes[hole_index]

func reset() -> void:
	current_course_descriptor = null
	player_scores.clear()
	hole_index = -1
	pass

func get_score_by_player_id(player_id : int) -> PlayerScore:
	for score : PlayerScore in player_scores:
		if score.player_id == player_id:
			return score
	return null
