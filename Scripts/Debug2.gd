extends Label


func _ready() -> void:
	Events.player_authority_changed.connect(on_dood)


func on_dood(_player : Player, player_id : int):
	if player_id == multiplayer.get_unique_id():
		text = "PID: " + str(player_id)
