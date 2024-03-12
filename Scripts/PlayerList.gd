extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.player_spawned.connect(on_player_spawned)
	Events.someone_disconnected.connect(on_disconnect)

func on_player_spawned(player : Player):
	create_label(player.player_name, player.player_id, player.player_color)

func create_label(player_name : String, player_id : int, player_color : Color):
	print("Adding player label for ", player_name, " on player ", str(player_id), " spawned!")
	var label = Label.new()
	label.name = str(player_id)
	label.text = player_name
	label.modulate = player_color
	add_child(label, true)

func on_disconnect(_player_id : int, player_name : String):
	for child : Label in get_children():
		if child.text == str(player_name):
			child.queue_free()
