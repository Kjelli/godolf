extends State
class_name PlayerSwinging

@export var player : Player
@export var animation_tree : AnimationTree
@export var direction : Direction

var club : Node2D

func OnEnter():
	var children = player.get_children()
	for child in children:
		if child is Club:
			club = child

	var leftSwing = PI * club.charge / club.max_charge
	var rightSwing = - PI * club.charge / club.max_charge

	var afterSwing = leftSwing if direction.value().x < 0 else rightSwing

	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(club, "rotation", 0, 0.05)
	tween.tween_callback(_on_swing)
	tween.tween_property(club, "rotation", afterSwing, 0.2)
	tween.tween_property(club, "rotation", 0, 0.1)

	tween.tween_callback(_on_after_swing)
	pass

func _on_swing():
	player.ball_in_range.hit(club.charge, direction)
	pass

func _on_after_swing():
	Transitioned.emit(self, "PlayerIdle")
	pass

func OnExit():
	club.queue_free()
	direction.set_eight_directional()
	animation_tree["parameters/conditions/swing"] = false
	pass

func Update(_delta : float):
	pass

func Physics_Update(_delta : float):
	pass

