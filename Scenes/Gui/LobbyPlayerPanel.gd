extends PanelContainer
class_name LobbyPlayerPanel

@export var player_name : String
@export var player_color : Color

@onready var player_name_label : Label = %PlayerNameLabel
@export var player_id : int:
	set(id):
		player_id = id
		on_player_id_set.call_deferred()

static func create(new_player_id : int, new_player_name : String, new_player_color : Color) -> LobbyPlayerPanel:
	var player_panel : LobbyPlayerPanel = preload("res://Scenes/Gui/LobbyPlayerPanel.tscn").instantiate()
	player_panel.player_id = new_player_id
	player_panel.player_name = new_player_name
	player_panel.player_color = new_player_color
	return player_panel

func on_player_id_set():
	set_multiplayer_authority(player_id, false)
	player_name_label.text = player_name
	player_name_label.modulate = player_color

func _ready() -> void:
	pass
