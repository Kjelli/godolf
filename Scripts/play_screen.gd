extends Node

@onready var networking : Networking = %Networking
@onready var scene_wrapper : Node = %SceneWrapper
@onready var course_spawner : MultiplayerSpawner = %CourseSpawner

@onready var main_menu : CanvasLayer = %MainMenu
@onready var singleplayer_menu : CanvasLayer = %SingleplayerMenu
@onready var multiplayer_menu : CanvasLayer = %MultiplayerMenu

@onready var hole_list : ItemList = %CourseList

@onready var host_button : Button = %HostButton
@onready var connect_button : Button = %ConnectButton
@onready var ip_edit : LineEdit = %IpEdit
@onready var port_edit : LineEdit = %PortEdit
@onready var color_picker : ColorRect = %ColorPicker

@onready var available_holes : Array

func _ready():
	DisplayServer.window_set_min_size(Vector2i(640, 480))

	color_picker.color = Color(randf(), randf(), randf(), 1)
	networking.player_color = color_picker.color

	populate_single_player_holes()
	hole_list.select(0)
	_on_course_list_item_selected(0)

func _process(_delta) -> void:
	if Input.is_action_just_pressed("cancel"):
		for child in scene_wrapper.get_children():
			scene_wrapper.remove_child(child)
			child.queue_free()

			if multiplayer.multiplayer_peer:
				multiplayer.multiplayer_peer.close()
				Networking.connected_players.clear()
				multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
			Networking.connected_players.clear()
		CourseContext.reset()
		singleplayer_menu.hide()
		multiplayer_menu.hide()
		main_menu.show()

func populate_single_player_holes():
	var courses = CourseLoader.list_courses()
	for course : CourseDescriptor in courses:
		for hole : HoleDescriptor in course.holes:
			available_holes.append(hole)
			hole_list.add_item(hole.display_name)
			course_spawner.add_spawnable_scene(hole.scene_path)

func _on_play_pressed():
	var hole_scene = load(scene_wrapper.selected_hole.scene_path)
	CourseContext.init_course(scene_wrapper.selected_hole.part_of_course_name, scene_wrapper.selected_hole.display_name, false)
	singleplayer_menu.hide()
	multiplayer_menu.hide()
	main_menu.hide()
	scene_wrapper.add_child.call_deferred(hole_scene.instantiate())

func _on_quit_pressed():
	get_tree().quit()

func _on_course_list_item_selected(index: int) -> void:
	scene_wrapper.selected_hole = available_holes[index]

func _on_quick_play_pressed() -> void:
	scene_wrapper.selected_hole = available_holes[randi_range(0, available_holes.size()-1)]
	_on_play_pressed()

func _on_name_edit_text_changed(new_text: String) -> void:
	networking.player_name = new_text

func _on_color_picker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mbe = event as InputEventMouseButton
		if mbe.button_index == 1 && mbe.pressed:
			color_picker.color = Color(randf(), randf(), randf(), 1)
			networking.player_color = color_picker.color

func _on_single_player_back_pressed() -> void:
	singleplayer_menu.hide()
	main_menu.show()

func _on_singleplayer_button_pressed() -> void:
	main_menu.hide()
	singleplayer_menu.show()

func _on_multiplayer_button_pressed() -> void:
	main_menu.hide()
	multiplayer_menu.show()

func _on_multiplayer_back_button_pressed() -> void:
	multiplayer_menu.hide()
	main_menu.show()
	pass # Replace with function body.

func _on_host_button_pressed() -> void:
	singleplayer_menu.hide()
	multiplayer_menu.hide()
	networking.host_server(port_edit.text.to_int())

func _on_connect_button_pressed() -> void:
	singleplayer_menu.hide()
	multiplayer_menu.hide()
	networking.connect_to_server(ip_edit.text, port_edit.text.to_int())
