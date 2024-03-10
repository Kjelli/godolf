extends Node

const PORT = 13337

@onready var course_wrapper : Node = %CourseWrapper

func _ready():
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_button_pressed.call_deferred()

func _on_host_button_pressed() -> void:
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.set_multiplayer_peer(peer)
	start_game()


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
func change_level(scene: PackedScene):
	# Remove old course if any.
	for c in course_wrapper.get_children():
		course_wrapper.remove_child(c)
		c.queue_free()
	# Add new level.
	course_wrapper.add_child(scene.instantiate())

func start_game():
	# Hide the UI and unpause to start the game.
	%MainMenu.hide()
	if multiplayer.is_server():
		#change_level.call_deferred(load("res://Scenes/Courses/course_01.tscn"))
		change_level.call_deferred(load("res://Scenes/Courses/" + course_wrapper.selected_course))
