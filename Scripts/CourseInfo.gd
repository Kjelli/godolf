extends Control

@onready var title : Label = $TitleLabel
@onready var par_label : Label = $ParLabel

func _ready():
	Golf.par_set.connect(update_par)

func update_par(par : int):
	par_label.text = "Par " + str(par)
