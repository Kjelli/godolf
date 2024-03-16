extends Node
class_name StateMachine

signal transitioned(from_state : State, state_name : String)

var states : Dictionary = {}

@export var initial_state : State
var current_state : State

func _ready():
	await owner.ready

	transitioned.connect(on_transition)

	for child in get_children():
		if child is State:
			child.state_machine = self
			states[child.name.to_lower()] = child
	if initial_state:
		current_state = initial_state
		initial_state.OnEnter()

func _process(delta : float):
	if current_state:
		current_state.Process(delta)

func _physics_process(delta : float):
	if current_state:
		current_state.Physics_Process(delta)

func on_transition(_from_state : State, new_state_name : String):
	if not new_state_name:
		return

	if new_state_name.to_lower() == current_state.name.to_lower():
		return

	if not states.has(new_state_name.to_lower()):
		return

	var new_state = states[new_state_name.to_lower()]

	if current_state:
		current_state.OnExit()

	Local.print(current_state.name + " -> " + new_state.name)
	current_state  = new_state
	new_state.OnEnter()

