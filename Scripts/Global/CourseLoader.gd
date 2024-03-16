extends Node

const base_path : String = "res://Scenes/Courses"

@onready var courses : Array

func _ready() -> void:
	load_courses()

func get_by_name(course_name : String) -> CourseDescriptor:
	for course : CourseDescriptor in courses:
		if course.course_name == course_name:
			return course
	return null

func list_courses() -> Array:
	return courses

func load_courses() -> void:
	var course_folder = DirAccess.open(base_path)
	course_folder.list_dir_begin()
	var folder_name = course_folder.get_next()
	while (folder_name != ""):
		if folder_name == ".." or folder_name == ".":
			# Directories, Skip.
			pass
		else:
			var course = scan_course(folder_name)
			if course.is_valid():
				courses.push_back(course)
		folder_name = course_folder.get_next()

func scan_course(folder_name : String) -> CourseDescriptor:
	var course_descriptor = CourseDescriptor.new()
	course_descriptor.course_name = folder_name

	var hole_folder = DirAccess.open(base_path + "/" + folder_name)
	hole_folder.list_dir_begin()
	var hole_file = hole_folder.get_next()
	var index = 0
	var par_total = 0
	while (hole_file != ""):
		var hole = scan_hole(folder_name, hole_file, index)
		par_total += hole.hole_par
		course_descriptor.holes.append(hole)
		index += 1

		hole_file = hole_folder.get_next()

	course_descriptor.par_total = par_total
	return course_descriptor

func scan_hole(course_folder : String, hole_file : String, index : int) -> HoleDescriptor:
	var hole = HoleDescriptor.new()
	hole.hole_index = index
	hole.part_of_course_name = course_folder
	hole.scene_path = base_path + "/" + course_folder + "/" + hole_file.replace(".remap", "")
	hole.display_name = hole_file.replace(".tscn", "").replace(".remap", "")
	hole.hole_par = try_get_hole_par(hole.scene_path)
	return hole

func try_get_hole_par(hole_scene_path : String):
	print("loading path ", hole_scene_path)
	var hole_scene = load(hole_scene_path) as PackedScene
	var inst = hole_scene.instantiate() as Hole
	var hole_par = inst.hole_par
	inst.queue_free()
	return hole_par
