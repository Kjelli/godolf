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

const CINEMATIC_REFRESH_TARGET_INTERVAL_SECONDS = 6

func _ready():
	Events.connect(Events.player_spawned.get_name(), _on_player_spawned)
	Events.connect(Events.player_authority_changed.get_name(), _on_player_authority_changed)
	Events.connect(Events.ball_shot.get_name(), _on_ball_shot)
	Events.connect(Events.ball_stopped.get_name(), _on_ball_stopped)
	Events.connect(Events.ball_sunk.get_name(), _on_ball_sunk)
	if is_cinematic:
		tilemap = get_tree().get_first_node_in_group("golf_map")
	pass

func _process(delta : float):
	if is_cinematic:
		handle_cinematic_movement(delta)
		return

	if current_target && is_instance_valid(current_target):
		position = position.lerp(current_target.position, lerp_weight)

func handle_cinematic_movement(delta : float):
	if cinematic_target == Vector2.ZERO || timer > CINEMATIC_REFRESH_TARGET_INTERVAL_SECONDS:
		var bounds : Rect2i = tilemap.get_used_rect()
		var size = bounds.size * tilemap.tile_set.tile_size / zoom.x
		var center = Vector2(size.x / 2, size.y / 2)
		if position == Vector2.ZERO:
			position = center
		cinematic_target = Vector2(randi_range(center.x - size.x / 3, center.x + size.x / 3),randi_range(center.y - size.y / 3, center.y + size.y / 3))
		timer = 0

	timer += delta
	position = position.lerp(cinematic_target, CINEMATIC_LERP)

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

static func create(as_cinematic : bool = false) -> Lakitu:
	var scn = preload("res://Scenes/lakitu.tscn")
	var instance = scn.instantiate()
	instance.is_cinematic = as_cinematic
	return instance
