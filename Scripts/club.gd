extends StaticBody2D
class_name Club

@export var max_charge : float = 100
@export var min_charge : float = 10
var charge : float = 0

func update_charge(charge_delta : float, x_direction : float):
	charge = min(max_charge, max(min_charge, charge + charge_delta))
	Events.charge_updated.emit(min_charge, charge, max_charge)

	var leftSwing = PI * charge / max_charge
	var rightSwing = - PI * charge / max_charge
	rotation = leftSwing if x_direction < 0 else rightSwing

func get_charge_percent():
	return charge / max_charge
