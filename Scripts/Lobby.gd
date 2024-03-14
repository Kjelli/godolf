extends Node

@onready var players : VBoxContainer = %Players
@onready var hole_count_label : Label = %HoleCountLabel

@onready var course_select : OptionButton = %CourseSelect
@onready var collision_toggle : CheckBox = %CollisionToggle
@onready var start_game_button : Button = %StartGameButton

@onready var courses : Array
@onready var selected_course : CourseDescriptor

func _ready() -> void:
	courses = CourseLoader.list_courses()
	for course : CourseDescriptor in courses:
		if multiplayer.is_server():
			if not selected_course:
				_on_course_select_item_selected(0)
		course_select.add_item(course.course_name)

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

func on_handshake_received(handshake : Handshake):
	var new_panel : LobbyPlayerPanel = LobbyPlayerPanel.create(handshake.player_id, handshake.player_name, handshake.player_color)
	new_panel.name = str(handshake.player_id)
	players.add_child(new_panel, true)

func on_someone_disconnected(player_id : int, _player_name : String):
	if players.has_node(str(player_id)):
		players.get_node(str(player_id)).queue_free()


func _on_start_game_button_pressed() -> void:
	var game_descriptor = GameDescriptor.create(selected_course, selected_course.holes[0], collision_toggle.button_pressed)
	Events.game_start_requested.emit(game_descriptor)
	pass # Replace with function body.

# Settings

func _on_course_select_item_selected(index: int) -> void:
	selected_course = courses[index - 1]
	hole_count_label.text = "%s holes" % selected_course.holes.size()
	start_game_button.disabled = false

