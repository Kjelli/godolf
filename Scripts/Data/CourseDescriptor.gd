extends Node
class_name CourseDescriptor

var course_name : String
var holes : Array = []
var par_total : int

func is_valid() -> bool:
	return holes.size() > 0
