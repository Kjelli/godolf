extends Control

@onready var movement_controls : Control = %MovementControls
@onready var swing_controls : Control = %SwingControls

enum ControlStates {
	Initial,
	Idle,
	Swinging
}

var current_state : int = ControlStates.Initial

var hide_tween : Tween

func _ready() -> void:
	Events.local_player_idle.connect(on_local_player_idle)
	Events.local_player_swinging.connect(on_local_player_swinging)

	movement_controls.modulate.a = 0
	movement_controls.hide()
	swing_controls.modulate.a = 0
	swing_controls.hide()

func on_local_player_idle():
	if current_state == ControlStates.Idle:
		return
	current_state = ControlStates.Idle

	if hide_tween:
		hide_tween.kill()
	await Local.tween(swing_controls, "modulate:a", 0, 0.2).finished
	swing_controls.hide()

	Local.tween(self, "modulate:a", 1, 0.2)

	movement_controls.show()
	await Local.tween(movement_controls, "modulate:a", 1, 0.2).finished
	hide_tween = Local.tween(self, "modulate:a", 0, 10)

func on_local_player_swinging():
	if current_state == ControlStates.Swinging:
		return
	current_state = ControlStates.Swinging

	if hide_tween:
		hide_tween.kill()
	await Local.tween(movement_controls, "modulate:a", 0, 0.2).finished
	movement_controls.hide()

	Local.tween(self, "modulate:a", 1, 0.2)

	swing_controls.show()
	await Local.tween(swing_controls, "modulate:a", 1, 0.2).finished
	hide_tween = Local.tween(self, "modulate:a", 0, 10)

func _exit_tree() -> void:
	Events.local_player_idle.disconnect(on_local_player_idle)
	Events.local_player_swinging.disconnect(on_local_player_swinging)
