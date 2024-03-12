extends Camera2D
class_name Lakitu

const REFRESH_TARGET_INTERVAL_SECONDS = 1
const PLAYER_LERP = 0.25
const BALL_LERP = 1.0
const CINEMATIC_LERP = 0.001

var is_cinematic : bool = false

var current_target : Node2D

var timer = 0
var lerp_weight = 0.9

# Only used for cinematic!
var tilemap : TileMap
var cinematic_target : Vector2

func _enter_tree() -> void:
	Events.player_spawned.connect(_on_player_spawned)
	Events.player_authority_changed.connect(_on_player_authority_changed)
	Events.ball_shot.connect(_on_ball_shot)
	Events.ball_stopped.connect(_on_ball_stopped)
	Events.ball_sunk.connect(_on_ball_sunk)

func _ready():
	if is_cinematic:
		tilemap = get_tree().get_first_node_in_group("golf_map")
	pass

func _process(delta : float):
	if (not current_target) || !is_instance_valid(current_target):
		var players : Array[Node] = get_tree().get_nodes_in_group("players")
		for player in players:
			if player.name.to_int() == multiplayer.get_unique_id():
				current_target = player

	if current_target && !current_target.is_multiplayer_authority():
		current_target = null
		return


	if current_target && is_instance_valid(current_target):
		position = position.lerp(current_target.position, lerp_weight)

func _on_player_spawned(player : Player):
	if !player.is_multiplayer_authority():
		return
	current_target = player
	lerp_weight = PLAYER_LERP

func _on_player_authority_changed(player : Player, _player_id : int):
	if !player.is_multiplayer_authority():
		return
	current_target = player
	lerp_weight = PLAYER_LERP

func _on_ball_shot(ball : Ball):
	if !ball.is_multiplayer_authority():
		return
	current_target = ball
	lerp_weight = BALL_LERP

func _on_ball_stopped(ball : Ball):
	if !ball.is_multiplayer_authority():
		return
	current_target = ball.owning_player
	lerp_weight = PLAYER_LERP

func _on_ball_sunk(ball : Ball):
	if !ball.is_multiplayer_authority():
		return
	current_target = ball.owning_player
	lerp_weight = PLAYER_LERP

static func create() -> Lakitu:
	var scn = preload("res://Scenes/lakitu.tscn")
	var instance = scn.instantiate()
	return instance
