extends Node

class Score:
	var name : String
	var value : int

	static func create(name : String, value : int) -> Score:
		var score = Score.new()
		score.name = name
		score.value = value
		return score


var current_course_par = 3

signal par_set(par : int)

func get_score(shot_count : int, par : int) -> Score:

	var diff = shot_count - par
	if shot_count == 1:
		return Score.create("Hole in one", diff)

	if diff < -3:
		return Score.create("Nuts", diff)
	if diff == -3:
		return Score.create("Albatross", diff)
	elif diff == -2:
		return Score.create("Eagle", diff)
	elif diff == -1:
		return Score.create("Birdie", diff)
	elif diff == 0:
		return Score.create("Par", diff)
	elif diff == 1:
		return Score.create("Bogey", diff)
	elif diff == 2:
		return Score.create("Double bogey", diff)
	elif diff == 3:
		return Score.create("Triple bogey", diff)
	elif diff > 3:
		return Score.create("Noob", diff)
	else:
		return Score.create("Wow", diff)

func set_par(par : int):
	current_course_par = par
	par_set.emit(par)
