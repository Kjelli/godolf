extends Node2D
class_name Lakitu

var current_target : Node2D

const SPEED = 10
const REFRESH_TARGET_INTERVAL_SECONDS = 1
var timer = 0

func _ready():
	Events.connect(Events.player_spawned.get_name(), _on_player_spawned)
	Events.connect(Events.ball_shot.get_name(), _on_ball_shot)
	Events.connect(Events.ball_stopped.get_name(), _on_ball_stopped)
	Events.connect(Events.ball_sunk.get_name(), _on_ball_sunk)
	pass

func _process(delta):
	if not current_target and timer >= REFRESH_TARGET_INTERVAL_SECONDS:
		find_target()
		timer = 0
		return
	elif not current_target:
		timer += delta

	if current_target && is_instance_valid(current_target):
		position = position.lerp(current_target.position, delta * SPEED)

func _on_player_spawned(player : Player):
	current_target = player

func _on_ball_shot(ball : Ball):
	current_target = ball

func _on_ball_stopped(ball : Ball):
	current_target = ball.owning_player

func _on_ball_sunk(ball : Ball):
	current_target = ball.owning_player

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

static func create() -> Lakitu:
	var scn = preload("res://Scenes/lakitu.tscn")
	return scn.instantiate()
