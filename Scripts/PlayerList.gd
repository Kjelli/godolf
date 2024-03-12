extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.handshake_received.connect(on_handshake)
	Events.someone_disconnected.connect(on_disconnect)
	create_label(Networking.player_name, multiplayer.get_unique_id(), Networking.player_color)

func on_handshake(handshake : Handshake):
	create_label(handshake.player_name, handshake.player_id, handshake.player_color)

func create_label(player_name : String, _player_id : int, player_color : Color):
	var label = Label.new()
	label.modulate = player_color
	label.text = player_name
	add_child(label)

func on_disconnect(_player_id : int, player_name : String):
	for child : Label in get_children():
		if child.text == str(player_name):
			child.queue_free()
			break
