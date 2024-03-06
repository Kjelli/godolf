extends Node2D

@onready var items : ItemList = %CourseList
@onready var courses : PackedStringArray
var selected_course : String

func _ready():
	scan_scenes()
	pass # Replace with function body.

func scan_scenes():
	var paths = []
	var numScenes = 0
	var dir = DirAccess.open("res://Scenes/Courses")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		print(file_name)
		if file_name == ".." or file_name == ".":
			# Directories, Skip.
			pass
		else:
			paths.push_back(file_name.replace(".tscn", ""))
		if dir.current_is_dir():
			numScenes += 1
		file_name = dir.get_next()
	print("Got a list of "+str(numScenes)+" files")
	for scene in paths:
		items.add_item(scene)
		courses.append(scene)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/Courses/" + selected_course + ".tscn")
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()


func _on_course_list_item_selected(index: int) -> void:
	selected_course = courses[index]
	pass # Replace with function body.
