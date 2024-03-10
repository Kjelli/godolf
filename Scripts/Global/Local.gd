extends Node

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)

func print(msg : String = ""):
	var local_peer_id = get_tree().get_multiplayer().get_unique_id()
	var name = Networking.player_name
	var alias = name + " (server)" if local_peer_id == 1 else name + " (" +str(local_peer_id) + ")"

	print("[", alias, "] ", msg)

func peer_connected(c_player_id : int):
	#self.print("Player " + str(c_player_id) + " connected")
	pass

func peer_disconnected(d_player_id : int):
	#self.print("Player " + str(d_player_id) + " disconnected")
	pass

func print_rpc(msg : String = ""):
	var peer_id = multiplayer.get_remote_sender_id()
	var receiver_id = multiplayer.get_unique_id()
	print("[RPC]: ", peer_id, " -> ", receiver_id)
	self.print(msg)
