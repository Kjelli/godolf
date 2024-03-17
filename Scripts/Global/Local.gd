extends Node

func print(msg : String = ""):
	var local_peer_id = get_tree().get_multiplayer().get_unique_id()
	var local_name = Networking.player_name
	var alias = local_name + " (server)" if local_peer_id == 1 else local_name + " (" +str(local_peer_id) + ")"

	print("[", alias, "] ", msg)

func print_rpc(msg : String = ""):
	var peer_id = multiplayer.get_remote_sender_id()
	var receiver_id = multiplayer.get_unique_id()
	print("[RPC]: ", peer_id, " -> ", receiver_id)
	self.print(msg)

func tween(object : Object, property : NodePath, final_val : Variant, duration : float) -> Tween:
	var tween = get_tree().create_tween()
	tween.tween_property(object, property, final_val, duration)
	return tween

func timer(duration : float) -> SceneTreeTimer:
	return get_tree().create_timer(duration)
