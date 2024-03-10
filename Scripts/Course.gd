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
	Local.print(" Player connected: " + str(player_id) + "!")
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

	await get_tree().create_timer(1).timeout

	_handoff.rpc(player.get_path(), player_id)
	_handoff.rpc(ball.get_path(), player_id)

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

@rpc("authority", "call_local", "reliable")
func _handoff(node_path : NodePath, auth_id):
	var peer_id = multiplayer.get_remote_sender_id()
	var receiver_id = multiplayer.get_unique_id()
	print()
	print("[RPC]: ", peer_id, " -> ", receiver_id)
	Local.print(" I will make sure that " + str(node_path) + " has auth id " + str(auth_id))
	await get_tree().create_timer(1).timeout
	var node = $Players.get_node(node_path)
	if node:
		Local.print(" I did mp auth with this node: " + node.name + " (set it to " + str(auth_id) +")")
		node.set_multiplayer_authority(auth_id)
		if node.player_id:
			node.player_id = auth_id
	else:
		Local.print(" I couldn't find them ?!?!?!??!?!?!?!")
