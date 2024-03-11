extends Node2D
class_name Course

@onready var spawn_zone : SpawnZone = $SpawnZone

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

	Events.someone_disconnected.connect(del_player)

	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	# Events.handshake_received.connect(try_spawn)
	spawn_player(1, Networking.player_name)

	Events.handshake_received.connect(on_handshake)

func on_handshake(handshake : Handshake):
	spawn_player(handshake.player_id, handshake.player_name)

func spawn_player(player_id : int, player_name : String) -> void:
	var point = spawn_zone.draw_point()
	var player : Player = Player.create(player_id, player_name, point)

	var point2 = spawn_zone.draw_point()
	var ball : Ball = Ball.create(player, point2)

	%Players.add_child(player, true)
	%Balls.add_child(ball, true)

func spawn_camera(is_cinematic : bool = false) -> void:
	lakitu = Lakitu.create(is_cinematic)
	add_child(lakitu)

func del_player(id: int, player_name : String):
	Local.print(player_name + " disconnected!")
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()

	if not $Balls.has_node(str(id)):
		return
	$Balls.get_node(str(id)).queue_free()

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(spawn_player)
	multiplayer.peer_disconnected.disconnect(del_player)
