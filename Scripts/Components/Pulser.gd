extends Node2D
class_name Pulser

enum PulseDirection { Inwards, Outwards }

@export var min_radius := 2.0
@export var max_radius := 20.0
@export var length_seconds := 1.0
@export var pause_between := 0
@export var pulse_direction := PulseDirection.Outwards
@export var enabled := true

@onready var passed : float = pause_between
@onready var radius : float = min_radius
@onready var direction : int = pulse_direction

func _draw():
	if !enabled:
		return
	
	var progress = max(0, min(1, passed / length_seconds))
	draw_arc(position, radius, -PI, PI, 32, Color(1,1,1, 1 - progress))

func _process(_delta):
	if !enabled:
		return
	
	queue_redraw()
	
	passed += _delta
	var progress = max(0, min(1, passed / length_seconds))
	if passed < length_seconds:
		radius = min_radius + (1 - progress if direction == PulseDirection.Inwards else progress) * max_radius
	elif passed >= length_seconds + pause_between:
		passed = 0
		radius = min_radius
		
func enable():
	enabled = true
	queue_redraw()
	

func disable():
	enabled = false
	queue_redraw()
