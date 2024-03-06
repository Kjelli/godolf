extends Node2D
class_name Course

@onready var player_scene = preload("res://Scenes/player.tscn")
@onready var ball_scene = preload("res://Scenes/ball.tscn")
@export var spawn_zone : SpawnZone

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player("1")

func spawn_player(id : String):
	var point = spawn_zone.draw_point()

	var player : Player = player_scene.instantiate()
	add_child(player)
	player.set_id(id)
	player.global_position = point
	Events.player_spawned.emit(player)

	var ball : Ball = ball_scene.instantiate()
	add_child(ball)
	ball.global_position = point + Vector2(0, 10)
	ball.owning_player = player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
