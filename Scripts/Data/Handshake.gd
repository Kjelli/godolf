extends Node
class_name Handshake

var player_id : int
var player_name : String
var has_spawned : bool

static func create(new_player_id : int, new_player_name : String) -> Handshake:
	var handshake = Handshake.new()
	handshake.player_id = new_player_id
	handshake.player_name = new_player_name
	return handshake
