extends CharacterBody2D
class_name Ball

@export var weight := 0.75
@export var state_machine : StateMachine
@export var hit_particles : GPUParticles2D

@onready var is_in_goal : Goal
@onready var nearby_goal : Goal
@onready var acceleration : Vector2

var owning_player : Player
var last_shot_from : Vector2
var times_hit : int = 0

signal entered_goal_proximity
signal left_goal_proximity

func _process(delta):
	pass

func _physics_process(delta):
	acceleration = acceleration.lerp(Vector2.ZERO, 0.15)
	velocity = (velocity + acceleration * delta) * 0.985

	if velocity.length_squared() < 0.25 && acceleration.length_squared() < 0.25:
		velocity = Vector2.ZERO
		acceleration = Vector2.ZERO
		return
	pass

func _on_entered_goal_proximity(goal : Goal):
	nearby_goal = goal

func _on_left_goal_proximity(goal : Goal):
	if nearby_goal == goal:
		nearby_goal = null

func sink(goal : Goal):
	is_in_goal = goal
	if times_hit < Golf.current_course_par:
		goal.emit_particles()

func hit(charge : float, direction : Direction):
	last_shot_from = global_position
	times_hit += 1
	hit_particles.emitting = true
	velocity = (charge * 0.8 / (weight * 0.25)) * direction.value()
	Events.ball_shot.emit(self)
	print("Shot #" + str(times_hit))
