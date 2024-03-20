extends Node
class_name Networking

@onready var scene_wrapper : Node = %SceneWrapper
@onready var main_menu : CanvasLayer = %MainMenu

static var player_name : String
static var player_color : Color = Color.WHITE

static var connected_players : Array = []

func _ready() -> void:
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		host_server.call_deferred()

	multiplayer.connected_to_server.connect(on_connect_to_server)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.server_disconnected.connect(on_disconnect_from_server)

	Events.game_start_requested.connect(on_game_start_requested)
	Events.game_over.connect(on_game_over)

func host_server(port : int) -> bool:
	if player_name == "":
		OS.alert("A golfer needs a name!")
		return false
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return false
	multiplayer.set_multiplayer_peer(peer)

	# Add self as a known connection
	connected_players.append(Handshake.create(1, player_name, player_color))
	load_lobby()
	return true

func connect_to_server(url : String, port : int) -> bool:
	# Start as client.
	if player_name == "":
		OS.alert("A golfer needs a name!")
		return false

	if url == "":
		OS.alert("Need a remote to connect to.")
		return false
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(url, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return false
	multiplayer.set_multiplayer_peer(peer)
	load_lobby()

	return true

func on_connect_to_server() -> void:
	send_info.rpc_id(1, multiplayer.get_unique_id(), player_name, player_color.to_html())

func on_disconnect_from_server():
	for c in scene_wrapper.get_children():
		scene_wrapper.remove_child(c)
		c.queue_free()
	main_menu.show()

@rpc("any_peer", "call_remote")
func send_info(received_player_id : int, received_player_name : String, received_player_color : String) -> void:
	var handshake = Handshake.create(
		received_player_id,
		received_player_name,
		Color(received_player_color))
	connected_players.append(handshake)
	Events.handshake_received.emit(handshake)

	# Send all connections back
	if multiplayer.is_server():
		# notify new client about old clients
		for existing_peer : Handshake in connected_players:
			if existing_peer.player_id == received_player_id:
				continue
			send_info.rpc_id(received_player_id, existing_peer.player_id, existing_peer.player_name, existing_peer.player_color.to_html())

		# notify old clients about new client
		for existing_peer : Handshake in connected_players:
			if existing_peer.player_id == 1 || existing_peer.player_id == received_player_id:
				continue
			send_info.rpc_id(existing_peer.player_id, received_player_id, received_player_name, received_player_color)

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
func change_level(game_descriptor: GameDescriptor) -> void:
	# Remove old course if any.
	clear_scenes()

	# Add new level.
	var hole_descriptor : HoleDescriptor = game_descriptor.next_hole
	CourseContext.init_course.rpc(game_descriptor.course.course_name, hole_descriptor.display_name, game_descriptor.use_ball_collision)

	var hole : Hole = load(hole_descriptor.scene_path).instantiate()
	scene_wrapper.add_child(hole)


func load_lobby() -> void:
	# Hide the UI and unpause to start the game.
	main_menu.hide()
	# Remove old course if any.
	clear_scenes()

	if multiplayer.is_server():
		var lobby = load("res://Scenes/lobby.tscn").instantiate()
		scene_wrapper.add_child(lobby)

func load_course() -> void:
	# Hide the UI and unpause to start the game.
	main_menu.hide()
	if multiplayer.is_server():
		change_level.call_deferred(load("res://Scenes/Courses/" + scene_wrapper.selected_course))

func clear_scenes() -> void:
	for c in scene_wrapper.get_children():
		scene_wrapper.remove_child(c)
		c.queue_free()

func on_game_over() -> void:
	CourseContext.reset()
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		clear_scenes()
		main_menu.show()
	elif multiplayer.is_server():
		load_lobby()

func on_game_start_requested(game_descriptor : GameDescriptor):
	change_level.call_deferred(game_descriptor)
