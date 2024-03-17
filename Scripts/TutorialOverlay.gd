extends MarginContainer

@onready var movement_controls : Control = %MovementControls
@onready var swing_controls : Control = %SwingControls

func _ready() -> void:
	Events.local_player_idle.connect(on_local_player_idle)
	Events.local_player_swinging.connect(on_local_player_swinging)

	movement_controls.modulate.a = 0
	movement_controls.hide()
	swing_controls.modulate.a = 0
	swing_controls.hide()

func on_local_player_idle():
	await Local.tween(swing_controls, "modulate:a", 0, 0.2).finished
	swing_controls.hide()

	movement_controls.show()
	await Local.tween(movement_controls, "modulate:a", 1, 0.2).finished
	pass

func on_local_player_swinging():
	await Local.tween(movement_controls, "modulate:a", 0, 0.2).finished
	movement_controls.hide()

	swing_controls.show()
	await Local.tween(swing_controls, "modulate:a", 1, 0.2).finished
	pass

func _exit_tree() -> void:
	Events.local_player_idle.disconnect(on_local_player_idle)
	Events.local_player_swinging.disconnect(on_local_player_swinging)
