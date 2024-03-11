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
	old_spawn_player(1)

	multiplayer.peer_connected.connect(old_spawn_player)

#func try_spawn(handshake : Handshake):
	#if multiplayer.is_server():
		## spawn at server
		#spawn_player(handshake.player_id, handshake.player_name)
#
		## spawn new one at existing places
		#for peer : Handshake in Networking.connected_players:
			#if peer.player_id == 1:
				#continue
			#spawn_player.rpc_id(peer.player_id, handshake.player_id, handshake.player_name)
#
		## spawn existing one at new place
		#for peer : Handshake in Networking.connected_players:
			#if peer.player_id == handshake.player_id:
				#continue
			#spawn_player.rpc_id(handshake.player_id, peer.player_id, peer.player_name)

#@rpc("authority", "call_local", "reliable", 1)
#func spawn_player(player_id : int, player_name : String) -> void:
	#Local.print("Spawning " + str(player_name) + " locally with id " + str(player_id))
#
	#if not multiplayer.is_server():
		#await Local.timer(0.2).timeout
#
	#var point = spawn_zone.draw_point()
	#var player : Player = Player.create(player_id, player_name, point)
#
	#var point2 = spawn_zone.draw_point()
	#var ball : Ball = Ball.create(player, point2)
#
	#%Players.add_child(player, true)
	#%Players.add_child(ball, true)
#
	#print("Spawned ", player_name, " with path ", player.get_path())

func old_spawn_player(player_id : int) -> void:
	var point = spawn_zone.draw_point()
	var player : Player = Player.create(player_id, "player_name", point)

	var point2 = spawn_zone.draw_point()
	var ball : Ball = Ball.create(player, point2)

	%Players.add_child(player, true)
	%Balls.add_child(ball, true)

func spawn_camera(is_cinematic : bool = false) -> void:
	lakitu = Lakitu.create(is_cinematic)
	add_child(lakitu)

func del_player(id: int, player_name : String):
	Local.print(player_name + " disconnected!")
	if not $Players.has_node("player_" + str(id)):
		return
	$Players.get_node("player_" + str(id)).queue_free()

	if not $Balls.has_node("ball_" + str(id)):
		return
	$Balls.get_node("ball_" + str(id)).queue_free()

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(old_spawn_player)
	multiplayer.peer_disconnected.disconnect(del_player)
