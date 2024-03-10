extends Node
class_name Handshake

var player_id : int
var player_name : String
var has_spawned : bool

static func create(player_id : int, player_name : String) -> Handshake:
	var handshake = Handshake.new()
	handshake.player_id = player_id
	handshake.player_name = player_name
	return handshake
