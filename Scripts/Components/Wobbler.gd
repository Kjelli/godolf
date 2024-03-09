extends Node

@onready var parent : CanvasItem
var time_alive = 0
func _ready() -> void:
	parent = get_parent()
	parent.pivot_offset = parent.get_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_alive += delta
	parent.position.y = parent.position.y + 0.025 * cos(time_alive * 2)
	parent.scale = Vector2(0.975 + 0.025 * parent.scale.x * sin(time_alive * 1.5) * sin(time_alive * 6), 0.975 + 0.025 * parent.scale.y * cos(time_alive * 6) * cos(time_alive * 1.5))
	pass
