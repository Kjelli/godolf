extends CharacterBody2D
class_name Ball

const TILE_MAP_GROUND_LAYER : int = 0
const TILE_MAP_HILL_LAYER : int = 2
const SPECIAL_LAYER : int = 8

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

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		sync_aim_vis = aim_line.visible
		sync_aim_scale = aim_line.scale
		sync_aim_rot = aim_line.rotation
		sync_mod_a = sprite.modulate.a
		sync_splash_emit = splash_particles.emitting
		sync_scale = scale
	else:
		aim_line.visible = sync_aim_vis
		splash_particles.emitting = sync_splash_emit
		Local.tween(sprite, "modulate:a", sync_mod_a, 0.1)
		Local.tween(self, "scale", sync_scale, 0.1)
		Local.tween(aim_line, "scale", sync_aim_scale, 0.1)
		Local.tween(aim_line, "rotation", aim_line.rotation + wrapf(sync_aim_rot - aim_line.rotation, -PI, PI), 0.1)

func _physics_process(delta):
	if is_multiplayer_authority():
		update_local_physics(delta)
	else:
		get_tree().create_tween().tween_property(self, "position", sync_pos, 0.05)

func update_local_physics(delta : float):
	acceleration = acceleration.lerp(Vector2.ZERO, 0.15)
	velocity = (velocity + acceleration * delta) * 0.985

	var tile_type = check_tile_type_under_ball()
	var elevation = check_elevation_under_ball()

	if velocity.length_squared() < 0.25 && acceleration.length_squared() < 0.25 && not elevation:
		if is_moving && !is_in_water:
			pulser.enable()
			is_moving = false
			current_trail.stop()
			current_trail = null
			Events.ball_stopped.emit(self)
			velocity = Vector2.ZERO
			acceleration = Vector2.ZERO

	elif not is_moving:
		is_moving = true
		pulser.disable()
		current_trail = Trail.create()
		add_child(current_trail)

	if nearby_goal:
		var direction = (nearby_goal.transform.get_origin() - transform.get_origin()).normalized()
		var distance = (nearby_goal.transform.get_origin() - transform.get_origin()).length()

		var bowl_range = 14
		if distance < bowl_range:
			var distance_percent = 1 - distance / bowl_range
			scale = Vector2(0.3 + (1 - distance_percent) * 0.7, 0.3 + (1 - distance_percent) * 0.7)
			acceleration = (direction * distance) * 8
		else:
			scale = Vector2(1.0, 1.0)

		if distance < 4 && velocity.length_squared() < 2500:
			sink(nearby_goal)

	if is_in_goal:
		velocity = (is_in_goal.position - position).normalized() * 10

	if is_in_goal && !is_tweening_into_goal:
		is_tweening_into_goal = true
		acceleration = Vector2.ZERO
		var sinkTween = get_tree().create_tween()
		sinkTween.set_ease(Tween.EASE_IN)
		sinkTween.tween_property(self, "position", is_in_goal.position, 0.2)
		sinkTween.tween_property(self, "modulate", Color(0,0,0,0), 0.5)
		sinkTween.tween_callback(on_sunk)

	if elevation:
		velocity += 5 * elevation * weight

	if tile_type == "Sand":
		velocity *= 0.95

	var collision = move_and_collide(velocity * delta)
	if collision:
		on_collision(collision)

	sync_pos = position

func check_tile_type_under_ball() -> Variant:
	var tile_pos = tile_map.local_to_map(transform.origin - tile_map.transform.origin)
	var tile_atlas_coords = tile_map.get_cell_atlas_coords(TILE_MAP_GROUND_LAYER, tile_pos, true)
	var tile_source_id = tile_map.get_cell_source_id(TILE_MAP_GROUND_LAYER, tile_pos, true)
	if tile_source_id == -1:
		return null
	var tile_source : TileSetSource = tile_map.tile_set.get_source(tile_source_id)
	if not tile_source:
		return null

	var tile_data = tile_source.get_tile_data(tile_atlas_coords, TILE_MAP_GROUND_LAYER)
	var custom_data = tile_data.get_custom_data("type")
	return custom_data

func check_elevation_under_ball() -> Vector2:
	var tile_pos = tile_map.local_to_map(transform.origin - tile_map.transform.origin)
	var tile_atlas_coords = tile_map.get_cell_atlas_coords(TILE_MAP_HILL_LAYER, tile_pos, true)
	if tile_atlas_coords == Vector2i(-1, -1):
		return Vector2.ZERO
	var tile_source_id = tile_map.get_cell_source_id(TILE_MAP_HILL_LAYER, tile_pos, true)
	if not tile_source_id:
		return Vector2.ZERO
	var tile_source : TileSetSource = tile_map.tile_set.get_source(tile_source_id)
	if not tile_source:
		return Vector2.ZERO

	var tile_data = tile_source.get_tile_data(tile_atlas_coords, 0)
	var custom_data = tile_data.get_custom_data("acceleration")
	return custom_data

func check_collision_tile(tile_rid : RID):
	var tile_pos = tile_map.get_coords_for_body_rid(tile_rid)
	var tile_atlas_coords = tile_map.get_cell_atlas_coords(0, tile_pos, false)
	var tile_source_id = tile_map.get_cell_source_id(0, tile_pos, false)

	var tile_source : TileSetSource = tile_map.tile_set.get_source(tile_source_id)
	var tile_data = tile_source.get_tile_data(tile_atlas_coords, 0)

	var custom_data = tile_data.get_custom_data("type")
	return custom_data

func on_collision(collision : KinematicCollision2D):
	var body = collision.get_collider()
	if body is TileMap:
		var tile_rid = collision.get_collider_rid()
		var body_collision_layer = PhysicsServer2D.body_get_collision_layer(tile_rid)
		var tile_type = check_collision_tile(tile_rid)
		if body_collision_layer == SPECIAL_LAYER and tile_type == "Water":
			sink_in_water()
		else:
			bounce_particles.emit_particle(transform, velocity, modulate, modulate, 0)
			velocity = velocity.bounce(collision.get_normal())

	if body is Ball:
		good_bounce(self, body)
		bounce_particles.emit_particle(body.transform, body.velocity, body.modulate, body.modulate, 0)

func on_sunk():
	Events.ball_sunk.emit(self)
	print("Nice! Sunk on shot #" + str(times_hit))
	call_deferred("queue_free")

func sink_in_water():
	is_in_water = true
	splash_particles.emitting = true
	velocity = Vector2.ZERO
	acceleration = Vector2.ZERO
	sprite.modulate.a = 0
	await get_tree().create_timer(1).timeout

	is_in_water = false
	sprite.modulate.a = 1
	global_position = last_shot_from
	Events.ball_stopped.emit(self)

func good_bounce(b1: Ball, b2: Ball):
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

func sink(goal : Goal):
	is_in_goal = goal
	if times_hit < Golf.current_course_par:
		goal.emit_particles()

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
