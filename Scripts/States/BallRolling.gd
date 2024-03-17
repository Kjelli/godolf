extends BallState

const TILE_MAP_GROUND_LAYER : int = 0
const TILE_MAP_HILL_LAYER : int = 2
const SPECIAL_LAYER : int = 8

@onready var tile_map : TileMap = get_tree().get_first_node_in_group("golf_map")

func OnEnter():
	pass

func OnExit():
	pass

func Process(_delta : float):
	sync_properties()
	pass

func Physics_Process(delta : float):
	ball.acceleration = ball.acceleration.lerp(Vector2.ZERO, 0.15)
	ball.velocity = (ball.velocity + ball.acceleration * delta) * 0.985

	var tile_type = check_tile_type_under_ball()
	var elevation = check_elevation_under_ball()

	if ball.velocity.length_squared() < 0.25 && ball.acceleration.length_squared() < 0.25 && not elevation:
		state_machine.transitioned.emit(self, "idle")
		return

	if ball.nearby_goal:
		var direction = (ball.nearby_goal.transform.get_origin() - ball.transform.get_origin()).normalized()
		var distance = (ball.nearby_goal.transform.get_origin() - ball.transform.get_origin()).length()

		var bowl_range = 14
		if distance < bowl_range:
			var distance_percent = 1 - distance / bowl_range
			ball.scale = Vector2(0.3 + (1 - distance_percent) * 0.7, 0.3 + (1 - distance_percent) * 0.7)
			ball.acceleration = (direction * distance) * 8
		else:
			ball.scale = Vector2(1.0, 1.0)

		if distance < 4 && ball.velocity.length_squared() < 2500:
			state_machine.transitioned.emit(self, "sinking")

	if elevation:
		ball.velocity += 5 * elevation * ball.weight

	if tile_type == "Sand":
		ball.velocity *= 0.95

	var collision = ball.move_and_collide(ball.velocity * delta)
	if collision:
		on_collision(collision)

	ball.sync_pos = ball.position

func check_tile_type_under_ball() -> Variant:
	var tile_pos = tile_map.local_to_map(ball.transform.origin - tile_map.transform.origin)
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

func on_collision(collision : KinematicCollision2D):
	var body = collision.get_collider()
	if body is TileMap:
		var tile_rid = collision.get_collider_rid()
		var body_collision_layer = PhysicsServer2D.body_get_collision_layer(tile_rid)
		var tile_type = check_collision_tile(tile_rid)
		if body_collision_layer == SPECIAL_LAYER and tile_type == "Water":
			state_machine.transitioned.emit(self, "inwater")
			return
		else:
			ball.bounce_particles.emit_particle(ball.transform, ball.velocity, ball.modulate, ball.modulate, 0)
			ball.velocity = ball.velocity.bounce(collision.get_normal())

	if body is Ball:
		ball.good_bounce(ball, body)
		ball.bounce_particles.emit_particle(body.transform, body.velocity, body.modulate, body.modulate, 0)
