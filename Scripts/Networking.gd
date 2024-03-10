extends Node
class_name Networking

const PORT = 13337

@onready var course_wrapper : Node = %CourseWrapper

static var player_name : String

func _ready() -> void:
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_button_pressed.call_deferred()

	multiplayer.connected_to_server.connect(on_connect_to_server)

func _on_host_button_pressed() -> void:
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.set_multiplayer_peer(peer)
	start_game()

func on_connect_to_server() -> void:
	send_info.rpc_id(1, multiplayer.get_unique_id(), player_name)

@rpc("any_peer", "call_remote")
func send_info(received_player_id : int, received_player_name : String) -> void:
	Local.print("Handshake from "+ received_player_name + " with ID " + str(received_player_id))
	if multiplayer.is_server():
		send_info.rpc_id(received_player_id, 1, player_name)
		for peer in multiplayer.get_peers():
			if peer == 1 || peer == received_player_id:
				continue
			send_info.rpc_id(peer, received_player_id, received_player_name)

func _on_connect_button_pressed() -> void:
	# Start as client.
	var url : String = %IpEdit.text
	if url == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(url, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.set_multiplayer_peer(peer)
	start_game()

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene) -> void:
	# Remove old course if any.
	for c in course_wrapper.get_children():
		course_wrapper.remove_child(c)
		c.queue_free()
	# Add new level.
	course_wrapper.add_child(scene.instantiate())

func start_game() -> void:
	# Hide the UI and unpause to start the game.
	%MainMenu.hide()
	if multiplayer.is_server():
		#change_level.call_deferred(load("res://Scenes/Courses/course_01.tscn"))
		change_level.call_deferred(load("res://Scenes/Courses/" + course_wrapper.selected_course))
