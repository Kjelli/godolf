extends Label


func _ready() -> void:
	text = "ID: " + str(Local.foo)
