extends StaticBody2D
class_name Club

@export var max_charge : float = 100
@export var min_charge : float = 10
@export var charge : float = 0

func update_charge(player_id : int, charge_delta : float, x_direction : float):
	charge = min(max_charge, max(min_charge, charge + charge_delta))

	var leftSwing = PI * charge / max_charge
	var rightSwing = - PI * charge / max_charge
	Local.tween(self, "rotation",leftSwing if x_direction < 0 else rightSwing, 0.1)

	Events.charge_updated.emit(player_id, min_charge, charge, max_charge)

func get_charge_percent():
	return charge / max_charge
