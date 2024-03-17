extends CharacterBody2D
class_name Ball

signal entered_goal_proximity
signal left_goal_proximity

@export var weight := 0.75

@onready var hit_particles : GPUParticles2D = %HitParticles
@onready var splash_particles : GPUParticles2D = %SplashParticles
@onready var bounce_particles : GPUParticles2D = %BounceParticles
@onready var pulser : Pulser = %Pulser
@onready var aim_line : Sprite2D = %AimLine
@onready var sprite : Sprite2D = %Sprite
@onready var tile_map : TileMap = get_tree().get_first_node_in_group("golf_map")

var acceleration : Vector2
var owning_player : Player
var is_in_goal : Goal
var nearby_goal : Goal
var current_trail : Trail

var is_moving : bool
var is_in_water : bool
var last_shot_from : Vector2
var times_hit : int = 0
var is_tweening_into_goal : bool

@export var aim_color : Color
@export var sync_pos : Vector2
@export var sync_is_moving : bool
@export var sync_aim_vis : bool
@export var sync_aim_scale : Vector2
@export var sync_aim_rot : float
@export var sync_mod_a : float
@export var sync_splash_emit : bool
@export var sync_scale : Vector2

# Set by the authority, synchronized on spawn.
@export var player_id : int:
	set(id):
		player_id = id
		on_player_id_set.call_deferred()

func on_player_id_set():
	set_multiplayer_authority(player_id, false)
	$DataSynchronizer.set_multiplayer_authority(player_id)
	modulate = Color(aim_color)
	aim_line.modulate = Color(aim_color)

	if !is_multiplayer_authority():
		pulser.disable()

static func create(player : Player, initial_position : Vector2) -> Ball:
	var ball : Ball = preload("res://Scenes/ball.tscn").instantiate()
	ball.owning_player = player
	ball.aim_color = player.player_color
	ball.player_id = player.player_id
	ball.position = initial_position
	ball.sync_pos = initial_position
	ball.last_shot_from = initial_position
	ball.name = str(ball.player_id)
	return ball;

func _ready():
	position = sync_pos

	if not owning_player:
		var eligible_players = get_tree().get_nodes_in_group("players")
		for eligible_player in eligible_players:
			if eligible_player.name == str(player_id):
				owning_player = eligible_player

func trigger_sink():
	on_sunk.rpc(owning_player.player_id, owning_player.player_name, times_hit)

@rpc("any_peer", "call_local", "reliable")
func on_sunk(_player_id : int, player_name : String, _times_hit : int):
	Events.ball_sunk.emit(_player_id, player_name, _times_hit)
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer || multiplayer.is_server():
		queue_free()

static func good_bounce(b1: Ball, b2: Ball):
	# get angle of collision
	var theta = - atan2((b2.position.y - b1.position.y), (b2.position.x - b1.position.x))

	# transform for 1d elastic collision
	var v1 = b1.velocity.rotated(theta)
	var v2 = b2.velocity.rotated(theta)

	# conservation of kinetic energy and momentum
	var v1after = Vector2((b1.weight - b2.weight)/(b1.weight + b2.weight) * v1.x + (2 * b2.weight)/(b1.weight + b2.weight) * v2.x, v1.y)
	var v2after = Vector2((2 * b1.weight)/(b1.weight + b2.weight) * v1.x + (b2.weight - b1.weight)/(b1.weight + b2.weight) * v2.x, v2.y)

	v1after = v1after.rotated(-theta)
	v2after = v2after.rotated(-theta)

	# rotate back to 2d vectors
	b1.bounced.rpc_id(b1.player_id, b1.get_path(), v1after)
	b2.bounced.rpc_id(b2.player_id, b2.get_path(), v2after)

@rpc("any_peer", "call_local", "reliable")
func bounced(ball_path : NodePath, target_velocity : Vector2):
	if get_path() == ball_path:
		velocity = target_velocity

func _on_entered_goal_proximity(goal : Goal):
	nearby_goal = goal

func _on_left_goal_proximity(goal : Goal):
	if nearby_goal == goal:
		nearby_goal = null

func aim(charge : float, max_charge : float, direction : Vector2):
	aim_line.show()
	aim_line.scale.y = 1
	aim_line.scale.x = (charge / max_charge) * 2.5
	aim_line.rotation = direction.angle()

func hit(charge : float, direction : Vector2):
	aim_line.hide()
	last_shot_from = global_position
	times_hit += 1
	hit_particles.emitting = true
	velocity = (charge * 0.8 / (weight * 0.25)) * direction

	Events.ball_shot.emit(self)

	if CourseContext.use_ball_collision:
		await Local.timer(0.2).timeout
		set_collision_mask_value(5, true)
