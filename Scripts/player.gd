extends CharacterBody2D
class_name Player

var ball_in_range : Ball

# locals
@onready var animation_tree : AnimationTree = %AnimationTree
@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var player_input : Node = %PlayerInput
@onready var club : Club = %Club

@export var move_speed := 75

# Set by the authority, synchronized on spawn.
@export var player_id : int:
	set(id):
		player_id = id
		on_player_id_set.call_deferred()
@export var player_name : String
@export var player_color : Color

# syncables
@export var sync_pos : Vector2
@export var sync_club_vis : bool
@export var sync_club_rot : float
@export var sync_anim : String
@export var sync_direction : Vector2
@export var sync_is_swinging : bool

static func create(
	new_player_id : int,
	new_player_name : String,
	new_player_color : Color,
	initial_position : Vector2) -> Player:

	var player : Player = preload("res://Scenes/player.tscn").instantiate()
	player.player_id = new_player_id
	player.player_name = new_player_name
	player.player_color = new_player_color
	player.sync_pos = initial_position
	player.position = initial_position
	player.name = str(new_player_id)
	return player

func on_player_id_set():
	set_multiplayer_authority(player_id, false)
	%PlayerInput.set_multiplayer_authority(player_id)
	$DataSynchronizer.set_multiplayer_authority(player_id)

	if not is_multiplayer_authority():
		%Name.text = str(player_name)
		%Name.modulate = player_color

func _ready():
	Events.player_spawned.emit(self)
	position = sync_pos

func can_swing():
	if !ball_in_range:
		return false
	if ball_in_range.is_in_water:
		return false
	if ball_in_range.velocity != Vector2.ZERO:
		return false
	if !ball_in_range.is_multiplayer_authority():
		return false
	return true

func _on_ball_range_body_entered(body):
	if body is Ball:
		var ball : Ball = body
		if ball.player_id == player_id:
			ball_in_range = ball

func _on_ball_range_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is Ball:
		var ball : Ball = body
		if ball.player_id == player_id:
			ball_in_range = null

