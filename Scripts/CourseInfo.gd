extends Control

@onready var title : Label = $TitleLabel
@onready var par_label : Label = $ParLabel

func _ready():
	if CourseContext.current_hole_descriptor:
		if CourseContext.current_hole_descriptor.display_name:
			title.text = CourseContext.current_hole_descriptor.display_name

		if CourseContext.current_hole_descriptor.hole_par:
			par_label.text = "Par %d" % CourseContext.current_hole_descriptor.hole_par
