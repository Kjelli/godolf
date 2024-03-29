extends PanelContainer

@onready var options_menu : Container = %OptionsMenu

func _ready() -> void:
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		visible = !visible
		options_menu.hide()

func _on_resume_pressed() -> void:
	visible = false

func _on_quit_to_menu_pressed() -> void:
	Events.quit_to_menu.emit()

func _on_quit_to_desktop_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	hide()
	options_menu.show()
	pass # Replace with function body.
