extends Node2D
class_name Hole

@onready var spawn_zone : SpawnZone = $SpawnZone
@export var is_fake : bool
@export var hole_par : int = 3

var lakitu : Lakitu

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_fake:
		add_child(load("res://Scenes/hud.tscn").instantiate())
	spawn_camera()

	Events.someone_disconnected.connect(del_player)

	# We only need to spawn players on the server.
	if (not multiplayer.multiplayer_peer is OfflineMultiplayerPeer) && not multiplayer.is_server():
		return

	Events.handshake_received.connect(on_handshake)

	if Networking.connected_players.size() == 0:
		spawn_player(1, Networking.player_name, Networking.player_color)

	for existing_peer in Networking.connected_players:
		spawn_player_from_handshake.call_deferred(existing_peer)

func on_handshake(handshake : Handshake):
	spawn_player_from_handshake(handshake)

func spawn_player_from_handshake(handshake : Handshake):
	spawn_player(handshake.player_id, handshake.player_name, handshake.player_color)

func spawn_player(player_id : int, player_name : String, player_color : Color) -> void:
	var point = spawn_zone.draw_point()
	var player : Player = Player.create(player_id, player_name, player_color, point)
	if is_fake:
		player.is_bot = true

	var point2 = spawn_zone.draw_middle()
	var ball : Ball = Ball.create(player, point2)

	%Players.add_child(player, true)
	%Balls.add_child(ball, true)

func spawn_camera() -> void:
	lakitu = Lakitu.create()
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
	if (not multiplayer.multiplayer_peer is OfflineMultiplayerPeer) || not multiplayer.is_server():
		return
	Events.handshake_received.disconnect(on_handshake)
	Events.someone_disconnected.disconnect(del_player)
