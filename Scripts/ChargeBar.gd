extends Node2D

@onready var charge_rectangle : Sprite2D = $ChargeRectangle
@onready var charge_indicator : Sprite2D = $ChargeIndicator
@onready var original_size : Vector2 = charge_rectangle.scale
@onready var original_position : Vector2 = charge_indicator.position
@onready var bar : Sprite2D = $Bar
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(1,1,1,0)
	Events.connect(Events.charge_updated.get_name(), _on_update_charge_bar)
	Events.connect(Events.ball_shot.get_name(), _on_ball_shot)
	pass # Replace with function body.

func _on_update_charge_bar(player_id : int, _min_charge : float, current_charge : float, max_charge : float):
	if multiplayer.get_unique_id() != player_id:
		return

	var p = (current_charge / max_charge)
	get_tree().create_tween().tween_property(self, "modulate:a", 1, 0.5)
	get_tree().create_tween().tween_property($ChargeRectangle, "modulate", Color(p,1 - p,0,1), 0.5)
	charge_rectangle.scale = (Vector2(original_size.x * ((current_charge) / (max_charge) ), original_size.y))
	charge_indicator.position.x = original_position.x + original_size.x * ((current_charge) / (max_charge) )

func _on_ball_shot(_ball : Ball):
	get_tree().create_tween().tween_property(self, "modulate:a", 0, 0.5)
