extends TextureRect

@onready var timer : float
@onready var original_position : Vector2

func _ready() -> void:
	original_position = position
	Events.game_start_requested.connect(on_game_start)

func on_game_start(game_descriptor : GameDescriptor):
	hide_bg.rpc()

@rpc("any_peer", "call_local", "reliable")
func hide_bg():
	hide()

func _process(delta: float) -> void:
	timer += delta
	material["shader_parameter/amount"] = (0.5 + 0.5 * sin(timer * 4)) * 2 + 99
	position.y = original_position.y + (0.5 + 0.5*sin(timer / 4)) * 20
	pass
