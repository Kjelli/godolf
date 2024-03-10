extends Node

static var foo : int

func _ready() -> void:
	foo = multiplayer.get_unique_id()
	multiplayer.connected_to_server.connect(on_connected)

func print(msg : String = ""):
	print(get_tree().get_multiplayer().get_unique_id(), msg)

func on_connected():
	foo = multiplayer.get_unique_id()

func print_rpc(msg : String = ""):
	var peer_id = multiplayer.get_remote_sender_id()
	var receiver_id = multiplayer.get_unique_id()
	print("[RPC]: ", peer_id, " -> ", receiver_id)
	self.print(msg)
