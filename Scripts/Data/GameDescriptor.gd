extends Node
class_name GameDescriptor

var course : PackedScene
var use_ball_collision : bool

static func create(_course : PackedScene, _use_ball_collision : bool) -> GameDescriptor:
	var game_descriptor = GameDescriptor.new()
	game_descriptor.course = _course
	game_descriptor.use_ball_collision = _use_ball_collision
	return game_descriptor
