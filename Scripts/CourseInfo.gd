extends Control

@onready var title : Label = $TitleLabel
@onready var par_label : Label = $ParLabel

func _ready():
	title.text = CourseContext.current_hole_descriptor.display_name
	par_label.text = "Par %d" % CourseContext.current_hole_descriptor.hole_par
