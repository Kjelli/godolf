extends State

const TILE_MAP_GROUND_LAYER : int = 0
const TILE_MAP_HILL_LAYER : int = 2
const SPECIAL_LAYER : int = 8

@export var ball : Ball
@export var bounce_particles : GPUParticles2D

@onready var tile_map : TileMap = get_tree().get_first_node_in_group("golf_map")

var current_trail : Trail

func OnEnter():
	if current_trail:
		current_trail.stop()
	current_trail = Trail.create()
	ball.add_child(current_trail)

func OnExit():
	current_trail.stop()
	current_trail = null
	pass

func check_tile_type_under_ball() -> Variant:
	var tile_pos = tile_map.local_to_map(ball.transform.origin - tile_map.transform.origin)
	var tile_atlas_coords = tile_map.get_cell_atlas_coords(TILE_MAP_GROUND_LAYER, tile_pos, true)
	var tile_source_id = tile_map.get_cell_source_id(TILE_MAP_GROUND_LAYER, tile_pos, true)
	var tile_source : TileSetSource = tile_map.tile_set.get_source(tile_source_id)
	if not tile_source:
		return null

	var tile_data = tile_source.get_tile_data(tile_atlas_coords, TILE_MAP_GROUND_LAYER)
	var custom_data = tile_data.get_custom_data("type")
	return custom_data

func check_elevation_under_ball() -> Vector2:
	var tile_pos = tile_map.local_to_map(ball.transform.origin - tile_map.transform.origin)
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

func Update(_delta : float):
	if ball.is_in_goal:
		Transitioned.emit(self, "BallSinking")
		return

func Physics_Update(_delta : float):
	var tile_type = check_tile_type_under_ball()
	var elevation = check_elevation_under_ball()

	if ball.velocity.length_squared() < 0.25 && ball.acceleration.length_squared() < 0.25 && not elevation:
		Events.ball_stopped.emit(ball)
		Transitioned.emit(self, "BallIdle")
		return

	if ball.nearby_goal:
		var direction = (ball.nearby_goal.transform.get_origin() - ball.transform.get_origin()).normalized()
		var distance = (ball.nearby_goal.transform.get_origin() - ball.transform.get_origin()).length()

		var bowl_range = 14
		if distance < bowl_range:
			var distance_percent = 1 - distance / bowl_range
			ball.scale = Vector2(0.5 + (1 - distance_percent) * 0.5, 0.5 + (1 - distance_percent) * 0.5)
			ball.acceleration = (direction * distance) * 8
		else:
			ball.scale = Vector2(1.0, 1.0)

		if distance < 4 && ball.velocity.length_squared() < 2500:
			ball.sink(ball.nearby_goal)

	if elevation:
		ball.velocity += 5 * elevation * ball.weight

	if tile_type == "Sand":
		ball.velocity *= 0.95

	var collision = ball.move_and_collide(ball.velocity * _delta)
	if collision:
		on_collision(collision, _delta)

func on_collision(collision : KinematicCollision2D, delta : float):
	var body = collision.get_collider()
	if body is TileMap:
		var tile_rid = collision.get_collider_rid()
		var collision_layer = PhysicsServer2D.body_get_collision_layer(tile_rid)
		var tile_type = check_collision_tile(tile_rid)
		if collision_layer == SPECIAL_LAYER and tile_type == "Water":
			Transitioned.emit(self, "BallInWater")
		else:
			bounce_particles.emit_particle(ball.transform, ball.velocity, ball.modulate, ball.modulate, 0)
			ball.velocity = ball.velocity.bounce(collision.get_normal())

	if body is Ball:
		good_bounce(ball, body)
		bounce_particles.emit_particle(body.transform, body.velocity, body.modulate, body.modulate, 0)

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
	b1.velocity = v1after
	b2.velocity = v2after

