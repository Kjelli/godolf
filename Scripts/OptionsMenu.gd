extends PanelContainer

@onready var game_menu : Container = %GameMenu

@onready var master_volume : Slider = %MasterVolume
@onready var music_volume : Slider = %MusicVolume
@onready var sfx_volume : Slider = %SFXVolume

func _ready() -> void:
	master_volume.value = AudioServer.get_bus_volume_db(db_to_linear(AudioServer.get_bus_index("Master")))
	music_volume.value = AudioServer.get_bus_volume_db(db_to_linear(AudioServer.get_bus_index("Music")))
	sfx_volume.value = AudioServer.get_bus_volume_db(db_to_linear(AudioServer.get_bus_index("SFX")))
	hide()

func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_options_back_button_pressed() -> void:
	hide()
	game_menu.show()
