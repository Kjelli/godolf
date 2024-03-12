extends Node2D

@onready var items : ItemList = %CourseList
@onready var courses : PackedStringArray
@onready var host_button : Button = %HostButton
@onready var connect_button : Button = %ConnectButton
@onready var ip_edit : LineEdit = %IpEdit
@onready var color_picker : ColorRect = %ColorPicker

@onready var networking : Networking = %Networking
@onready var scene_wrapper : Node = %SceneWrapper
@onready var course_spawner : MultiplayerSpawner = %CourseSpawner

var colors : Array = [
	Color(1,1,1,1),
	Color(1,0,0,1),
	Color(0,1,0,1),
	Color(0,0,1,1),
]

func _ready():
	DisplayServer.window_set_min_size(Vector2i(640, 480))

	color_picker.color = Color(randf(), randf(), randf(), 1)
	networking.player_color = color_picker.color

	scan_scenes()
	items.select(0)
	_on_course_list_item_selected(0)

func _process(_delta) -> void:
	if Input.is_action_just_pressed("cancel"):
		%MainMenu.show()

func scan_scenes():
	var paths = []
	var dir = DirAccess.open("res://Scenes/Courses")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		if file_name == ".." or file_name == ".":
			# Directories, Skip.
			pass
		else:
			paths.push_back(file_name.replace(".remap",""))
		file_name = dir.get_next()
	for scene in paths:
		items.add_item(scene.replace(".tscn", ""))
		courses.append(scene)
		course_spawner.add_spawnable_scene("res://Scenes/Courses/" + scene)

func _on_play_pressed():
	var scene = load("res://Scenes/Courses/" + scene_wrapper.selected_course)
	%MainMenu.hide()
	add_child.call_deferred(scene.instantiate())
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()


func _on_course_list_item_selected(index: int) -> void:
	scene_wrapper.selected_course = courses[index]
	pass # Replace with function body.


func _on_quick_play_pressed() -> void:
	scene_wrapper.selected_course = courses[randi_range(0, courses.size()-1)]
	_on_play_pressed()
	pass # Replace with function body.

func _on_name_edit_text_changed(new_text: String) -> void:
	networking.player_name = new_text
	pass # Replace with function body.


func _on_color_picker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mbe = event as InputEventMouseButton
		if mbe.button_index == 1 && mbe.pressed:
			color_picker.color = Color(randf(), randf(), randf(), 1)
			networking.player_color = color_picker.color
	pass # Replace with function body.
