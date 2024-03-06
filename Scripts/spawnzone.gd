extends Node2D
class_name SpawnZone

func draw_point():
	var spawn_area : Rect2 = $Area.shape.get_rect()
	var random_spawn_x = randi_range($Area.global_position.x + spawn_area.position.x, $Area.global_position.x + spawn_area.position.x + spawn_area.size.y)
	var random_spawn_y = randf_range($Area.global_position.y + spawn_area.position.y, $Area.global_position.y + spawn_area.position.y + spawn_area.size.y)
	var spawn = Vector2(random_spawn_x,random_spawn_y)
	return spawn

func draw_middle():
	var spawn_area : Rect2 = $Area.shape.get_rect()
	var center_x = $Area.global_position.x + spawn_area.position.x + spawn_area.size.x / 2
	var center_y = $Area.global_position.y + spawn_area.position.y + spawn_area.size.y / 2
	var spawn = Vector2(center_x, center_y)
	return spawn
