extends Node2D
class_name Goal

@onready var nearby_balls = []
@onready var sparkles : GPUParticles2D = $GoodParticles

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for ball in nearby_balls:
		if !is_instance_valid(ball):
			nearby_balls.erase(ball)
			return

		if ball.is_in_goal:
			nearby_balls.erase(ball)
			return
	pass

func _on_goal_proximity_body_entered(body):
	if body is Ball:
		nearby_balls.append(body)
		body.entered_goal_proximity.emit(self)


func _on_goal_proximity_body_exited(body):
	if body is Ball:
		nearby_balls.erase(body)
		body.left_goal_proximity.emit(self)

func emit_particles():
	sparkles.emitting = true
