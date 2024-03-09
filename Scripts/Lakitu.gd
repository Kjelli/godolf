extends Node2D
class_name Lakitu

var current_target : Node2D
var is_cinematic : bool = false

const REFRESH_TARGET_INTERVAL_SECONDS = 1
const PLAYER_LERP = 0.05
const BALL_LERP = 1.0
const CINEMATIC_LERP = 0.001
var timer = 0
var lerp_weight = 0.9

# Only used for cinematic!
var tilemap : TileMap
var cinematic_target : Vector2

const CINEMATIC_REFRESH_TARGET_INTERVAL_SECONDS = 6
const CINEMATIC_SPEED = 0.5

func _ready():
	Events.connect(Events.player_spawned.get_name(), _on_player_spawned)
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
	if not current_target and timer >= REFRESH_TARGET_INTERVAL_SECONDS:
		find_target()
		timer = 0
		return
	elif not current_target:
		timer += delta

	if current_target && is_instance_valid(current_target):
		position = position.lerp(current_target.position, lerp_weight)

func handle_cinematic_movement(delta : float):
	if cinematic_target == Vector2.ZERO || timer > CINEMATIC_REFRESH_TARGET_INTERVAL_SECONDS:
		var bounds : Rect2i = tilemap.get_viewport_rect()
		var size = bounds.size * sqrt(tilemap.rendering_quadrant_size)
		var center = Vector2(bounds.get_center())
		if position == Vector2.ZERO:
			position = center
		cinematic_target = center + Vector2(randi_range(center.x - size.x / 16, center.x + size.x / 16),randi_range(center.y - size.y / 16, center.y + size.y / 16))
		timer = 0

	timer += delta
	position = position.lerp(cinematic_target, CINEMATIC_LERP)

func _on_player_spawned(player : Player):
	current_target = player
	lerp_weight = PLAYER_LERP

func _on_ball_shot(ball : Ball):
	current_target = ball
	lerp_weight = BALL_LERP

func _on_ball_stopped(ball : Ball):
	current_target = ball.owning_player
	lerp_weight = PLAYER_LERP

func _on_ball_sunk(ball : Ball):
	current_target = ball.owning_player
	lerp_weight = PLAYER_LERP

func find_target():
	var targets = get_tree().get_nodes_in_group("camera_targets")

	var player_i = targets.find(Player)
	if player_i:
		print("Spectating Player")
		current_target = targets[player_i]
		return

	var ball_i = targets.find(Ball)
	if ball_i:
		print("Spectating Ball")
		current_target = targets[ball_i]
		return

	var goal_i = targets.find(Ball)
	if goal_i:
		print("Spectating goal")
		current_target = targets[goal_i]
		return

static func create(is_cinematic : bool = false) -> Lakitu:
	var scn = preload("res://Scenes/lakitu.tscn")
	var instance = scn.instantiate()
	instance.is_cinematic = is_cinematic
	return instance
