extends Node2D
class_name Nice

@onready var initial_position := Vector2.ZERO

func _ready():
	position = initial_position
	
	modulate = Color(1,1,1,0)
	var fade = get_tree().create_tween()
	fade.tween_property(self, "modulate", Color(1,1,1,1), 0.5)
	fade.tween_property(self, "modulate", Color(1,1,1,0), 1.5)
	fade.tween_callback(queue_free)
	get_tree().create_tween().tween_property(self, "position", position + Vector2(0, -20), 2)

