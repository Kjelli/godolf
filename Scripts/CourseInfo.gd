extends Control

@onready var title : Label = $TitleLabel
@onready var par_label : Label = $ParLabel

var time_alive = 0

func _ready():
	Golf.par_set.connect(update_par)

func _process(delta: float) -> void:
	time_alive += delta
	position.y = position.y + 0.025 * cos(time_alive * 2)
	scale = Vector2(0.975 + 0.025 * scale.x * sin(time_alive * 1.5) * sin(time_alive * 6), 0.975 + 0.025 * scale.y * cos(time_alive * 6) * cos(time_alive * 1.5))

func update_par(par : int):
	par_label.text = "Par " + str(par)
