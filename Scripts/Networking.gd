extends Node
class_name Networking

const PORT = 25565

@onready var course_wrapper : Node = %CourseWrapper

static var player_name : String

static var connected_players : Array = []

func _ready() -> void:
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_button_pressed.call_deferred()

	multiplayer.connected_to_server.connect(on_connect_to_server)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func _on_host_button_pressed() -> void:
	if %NameEdit.text == "":
		OS.alert("A golfer needs a name!")
		return
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.set_multiplayer_peer(peer)
	connected_players.append(Handshake.create(1, player_name))
	load_course()

func _on_connect_button_pressed() -> void:
	# Start as client.
	if %NameEdit.text == "":
		OS.alert("A golfer needs a name!")
		return

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
	load_course()

func on_connect_to_server() -> void:
	send_info.rpc_id(1, multiplayer.get_unique_id(), player_name)

@rpc("any_peer", "call_remote")
func send_info(received_player_id : int, received_player_name : String) -> void:
	if not multiplayer.is_server():
		Local.print("Got handshake from " + str(received_player_id) + " having name " + received_player_name)
	var handshake = Handshake.create(received_player_id, received_player_name)
	connected_players.append(handshake)
	Events.handshake_received.emit(handshake)

	# Send all connections back
	if multiplayer.is_server():
		# notify new client about old clients
		for existing_peer : Handshake in connected_players:
			if existing_peer.player_id == received_player_id:
				continue
			send_info.rpc_id(received_player_id, existing_peer.player_id, existing_peer.player_name)

		# notify old clients about new client
		for existing_peer : Handshake in connected_players:
			if existing_peer.player_id == 1 || existing_peer.player_id == received_player_id:
				continue
			send_info.rpc_id(existing_peer.player_id, received_player_id, received_player_name)

func on_peer_disconnected(player_id : int):
	notify_disconnect(player_id)

@rpc("any_peer", "call_local")
func notify_disconnect(player_id : int):
	for existing_player : Handshake in connected_players:
		if existing_player.player_id == player_id:
			var idx = connected_players.find(existing_player)
			connected_players.remove_at(idx)
			Events.someone_disconnected.emit(existing_player.player_id, existing_player.player_name)
			break
	if multiplayer.is_server():
		for existing_peer : Handshake in connected_players:
			if existing_peer.player_id == 1 || existing_peer.player_id == player_id:
				continue
			notify_disconnect.rpc_id(existing_peer.player_id, player_id)

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene) -> void:
	# Remove old course if any.
	for c in course_wrapper.get_children():
		course_wrapper.remove_child(c)
		c.queue_free()
	# Add new level.
	course_wrapper.add_child(scene.instantiate())

func load_course() -> void:
	# Hide the UI and unpause to start the game.
	%MainMenu.hide()
	if multiplayer.is_server():
		#change_level.call_deferred(load("res://Scenes/Courses/course_01.tscn"))
		change_level.call_deferred(load("res://Scenes/Courses/" + course_wrapper.selected_course))
