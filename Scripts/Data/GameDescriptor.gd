extends Node
class_name GameDescriptor

var course : CourseDescriptor
var next_hole : HoleDescriptor
var use_ball_collision : bool

static func create(_course : CourseDescriptor, _next_hole : HoleDescriptor, _use_ball_collision : bool) -> GameDescriptor:
	var game_descriptor = GameDescriptor.new()
	game_descriptor.course = _course
	game_descriptor.next_hole = _next_hole
	game_descriptor.use_ball_collision = _use_ball_collision
	return game_descriptor
