extends Node2D
class_name Course

@onready var player_scene : PackedScene = preload("res://Scenes/player.tscn")
@onready var ball_scene : PackedScene = preload("res://Scenes/ball.tscn")
@onready var spawn_zone : SpawnZone = $SpawnZone

@export var course_par : int

var lakitu : Lakitu

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_camera()
	spawn_player("1")

func spawn_camera() -> void:
	lakitu = Lakitu.create()
	add_child(lakitu)

func spawn_player(id : String) -> void:
	var point = spawn_zone.draw_point()
	var middle = spawn_zone.draw_middle()

	var player : Player = player_scene.instantiate()
	add_child(player)
	player.set_id(id)
	player.global_position = point
	Events.player_spawned.emit(player)

	var ball : Ball = ball_scene.instantiate()
	add_child(ball)
	ball.global_position = middle
	ball.owning_player = player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if Input.is_action_just_pressed("cancel"):
		get_tree().change_scene_to_file("res://Scenes/play_screen.tscn")
