extends Node

@onready var players : VBoxContainer = %Players

@onready var course_select : OptionButton = %CourseSelect
@onready var collision_toggle : CheckBox = %CollisionToggle
@onready var start_game_button : Button = %StartGameButton

func _ready() -> void:
	for player : Handshake in Networking.connected_players:
		var new_panel : LobbyPlayerPanel = LobbyPlayerPanel.create(1, player.player_name, player.player_color)
		new_panel.name = str(1)
		players.add_child(new_panel)

	if multiplayer.is_server():
		Events.handshake_received.connect(on_handshake_received)
		Events.someone_disconnected.connect(on_someone_disconnected)
	else:
		course_select.disabled = true
		collision_toggle.disabled = true
		start_game_button.disabled = true

func on_handshake_received(handshake : Handshake):
	var new_panel : LobbyPlayerPanel = LobbyPlayerPanel.create(handshake.player_id, handshake.player_name, handshake.player_color)
	new_panel.name = str(handshake.player_id)
	players.add_child(new_panel, true)

func on_someone_disconnected(player_id : int, _player_name : String):
	if players.has_node(str(player_id)):
		players.get_node(str(player_id)).queue_free()

func _on_course_select_item_selected(index: int) -> void:
	pass # Replace with function body.


func _on_start_game_button_pressed() -> void:
	var selected_course = "res://Scenes/Courses/course_01.tscn"
	var game_descriptor : GameDescriptor = GameDescriptor.create(load(selected_course), collision_toggle.button_pressed)
	Events.game_start_requested.emit(game_descriptor)
	pass # Replace with function body.
