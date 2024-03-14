extends Control

@onready var shots : Label = $CountLabel

func _ready():
	Events.connect(Events.ball_shot.get_name(), update_count)
	Events.ball_sunk.connect(lock_count)

func update_count(ball : Ball):
	if ball.is_multiplayer_authority():
		shots.text = str(ball.times_hit)

func lock_count(player_id : int, _player_name : String, _times_hit : int):
	if player_id == multiplayer.get_unique_id():
		shots.modulate = Color(0, 1, 0, 1)
