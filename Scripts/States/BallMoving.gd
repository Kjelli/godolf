extends State

const TILE_MAP_GROUND_LAYER : int = 0
const TILE_MAP_HILL_LAYER : int = 2
const SPECIAL_LAYER : int = 8

@export var ball : Ball
@export var bounce_particles : GPUParticles2D

@onready var tile_map : TileMap = get_tree().get_first_node_in_group("golf_map")

var current_trail : Trail

func OnEnter():


func OnExit():
	current_trail.stop()
	current_trail = null
	pass

func Update(_delta : float):
	if ball.is_in_goal:
		Transitioned.emit(self, "BallSinking")
		return

func Physics_Update(_delta : float):


