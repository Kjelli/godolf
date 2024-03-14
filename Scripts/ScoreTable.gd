extends PanelContainer
class_name ScoreTable

@onready var table : GridContainer = %ScoreTable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var hole_count = CourseContext.current_course_descriptor.holes.size()
	var hole_index = CourseContext.current_hole_descriptor
	var player_scores = CourseContext.player_scores

	# leave space for name and total
	var column_count = hole_count + 2
	table.columns = column_count
	make_table_headers(column_count)

	modulate.a = 0.0

	Events.player_spawned.connect(on_player_spawn)
	Events.ball_sunk.connect(on_ball_sunk)
	Events.someone_disconnected.connect(remove_row_for_player)

func _process(_delta: float) -> void:
	if modulate.a < 0.5 && Input.is_action_pressed("view_score"):
		Local.tween(self, "modulate:a", 1.0, 0.15)
	elif modulate.a > 0.5 && not Input.is_action_pressed("view_score"):
		Local.tween(self, "modulate:a", 0.0, 0.15)

func make_table_headers(_size : int) -> void:
	var holes = CourseContext.current_course_descriptor.holes
	for column in range(_size):
		if column == 0:
			table.add_child(label("Hole", Color.DIM_GRAY))
		elif column == _size - 1:
			table.add_child(label("Total", Color.DIM_GRAY))
		else:
			table.add_child(label("%d" % column, Color.DIM_GRAY, column - 1 == CourseContext.hole_index))
	for column in range(_size):
		if column == 0:
			table.add_child(label("Par", Color.DIM_GRAY))
		elif column == _size - 1:
			table.add_child(label("%d" % CourseContext.current_course_descriptor.par_total))
		else:
			table.add_child(label("%d" % (holes[column - 1] as HoleDescriptor).hole_par, Color.YELLOW))

func on_player_spawn(player : Player) -> void:
	var player_score = CourseContext.get_score_by_player_id(player.player_id)
	if not player_score:
		player_score = PlayerScore.create(player.player_id, player.player_name, player.player_color, CourseContext.current_course_descriptor)
	make_row_for_player(player_score)

func make_row_for_player(player_score : PlayerScore) -> void:
	var scores = player_score.scores

	# leave space for name and total
	var column_count = scores.size() + 2
	for column in range(column_count):
		if column == 0:
			var player_name_label = label(player_score.player_name, player_score.player_color)
			player_name_label.name = str(player_score.player_id) if player_score.player_id != 1 else "server"
			table.add_child(player_name_label, true)
		elif column == column_count - 1:
			table.add_child(label("%d" % player_score.sum()))
		else:
			table.add_child(label("%d" % scores[column - 1], Color.WHITE, column -1 == CourseContext.hole_index))

func remove_row_for_player(player_score : PlayerScore) -> void:
	var column_count = player_score.scores.size() + 1

	var start_index = -1
	for i in table.get_children().size():
		var child = table.get_child(i) as Label
		var target_label_name = str(player_score.player_id) if player_score.player_id != 1 else "server"
		if child.name == target_label_name:
			start_index = child.name.to_int()
			break
	for column in range(column_count):
		var child = table.get_node(str(column + start_index))
		child.queue_free()

func on_ball_sunk(player_id : int, _player_name : String, times_hit : int) -> void:
	update_score_for_player(player_id, times_hit)

func update_score_for_player(player_id : int, score : int) -> void:
	var hole = CourseContext.hole_index
	var start_index = -1
	for child : Label in table.get_children():
		var target_label_name = str(player_id) if player_id != 1 else "server"
		if child.name == target_label_name:
			start_index = child.get_index()
			break
	# add one to offset player name
	var to_update = table.get_child(start_index + hole + 1) as Label
	to_update.text = str(score)


func label(text : String, color : Color = Color.WHITE, should_highlight = false) -> Label:
	var new_label = Label.new()
	new_label.text = text
	new_label.modulate = color
	new_label.name = str(table.get_children().size())
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	if should_highlight:
		new_label.modulate = Color.AQUA

	return new_label
