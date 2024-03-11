extends Node
class_name Handshake

var player_id : int
var player_name : String
var player_color : Color

static func create(new_player_id : int, new_player_name : String, new_player_color : Color) -> Handshake:
	var handshake = Handshake.new()
	handshake.player_id = new_player_id
	handshake.player_name = new_player_name
	handshake.player_color = new_player_color
	return handshake
