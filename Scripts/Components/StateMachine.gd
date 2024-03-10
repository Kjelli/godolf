extends Node
class_name StateMachine

@export var initial_state : State

# For synchronization
@export var current_state_name : String :
	set(new_state_name):
		if new_state_name.to_lower() == current_state_name:
			return

		var new_state = states.get(new_state_name.to_lower())
		if !new_state:
			return

		if current_state_name:
			states[current_state_name].OnExit()

		current_state_name = new_state.name.to_lower()
		new_state.OnEnter()

var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	if initial_state:
		current_state_name = initial_state.name.to_lower()
		initial_state.OnEnter()

func _process(delta : float):
	if current_state_name:
		states[current_state_name].Update(delta)

func _physics_process(delta : float):
	if current_state_name:
		states[current_state_name].Physics_Update(delta)

func on_child_transition(_state : State, new_state_name : String):
	current_state_name = new_state_name
