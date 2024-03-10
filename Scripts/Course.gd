extends Node2D
class_name Course

@onready var spawn_zone : SpawnZone = $SpawnZone
@onready var player_spawner : MultiplayerSpawner = %PlayerSpawner

@export var is_display_only : bool
@export var course_par : int = 3

var lakitu : Lakitu

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_display_only:
		spawn_camera(true)
		return

	add_child(load("res://Scenes/hud.tscn").instantiate())
	Golf.set_par(course_par)
	spawn_camera()

	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	player_spawner.set_multiplayer_authority(1)

	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		spawn_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		spawn_player(1)

func on_peer_connected(player_id : int):
	spawn_player(player_id)

func spawn_camera(is_cinematic : bool = false) -> void:
	lakitu = Lakitu.create(is_cinematic)
	add_child(lakitu)

func spawn_player(player_id : int) -> void:
	var point = spawn_zone.draw_point()
	var middle = spawn_zone.draw_point()

	var player : Player = Player.create(player_id, point)
	var ball : Ball = Ball.create(player, middle)

	%Players.add_child(player, true)
	%Players.add_child(ball, true)

func del_player(id: int):
	if not $Players.has_node("player_" + str(id)):
		return
	$Players.get_node("player_" + str(id)).queue_free()

	if not $Players.has_node("ball_" + str(id)):
		return
	$Players.get_node("ball_" + str(id)).queue_free()

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(spawn_player)
	multiplayer.peer_disconnected.disconnect(del_player)
