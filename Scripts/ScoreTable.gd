extends PanelContainer
class_name ScoreTable

@onready var table : GridContainer = %ScoreTable
@onready var show_score_regardless : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_table(CourseContext.current_course_descriptor, CourseContext.current_hole_descriptor)

	Events.game_proceeding.connect(on_game_proceeding)
	Events.player_spawned.connect(on_player_spawn)
	Events.player_score_updated.connect(on_player_score_updated)
	Events.someone_disconnected.connect(on_player_disconnected)

func setup_table(current_course_descriptor : CourseDescriptor, current_hole_descriptor : HoleDescriptor):
	if not current_course_descriptor:
		print("Missing course descriptor, cannot build score table!")
		return

	var hole_count = current_course_descriptor.holes.size()
	var hole_index = current_hole_descriptor

	# leave space for name and total
	var column_count = hole_count + 2
	table.columns = column_count
	make_table_headers(column_count)

	modulate.a = 0.0

func _exit_tree() -> void:
	Events.game_proceeding.disconnect(on_game_proceeding)
	Events.player_spawned.disconnect(on_player_spawn)
	Events.player_score_updated.disconnect(on_player_score_updated)
	Events.someone_disconnected.disconnect(on_player_disconnected)

func _process(_delta: float) -> void:
	if show_score_regardless:
		Local.tween(self, "modulate:a", 1.0, 0.15)
	elif modulate.a < 0.5 && Input.is_action_pressed("view_score"):
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
			table.add_child(label("%d" % column, Color.WHITE if column - 1 == CourseContext.hole_index else Color.DIM_GRAY))
	for column in range(_size):
		if column == 0:
			table.add_child(label("Par", Color.DIM_GRAY))
		elif column == _size - 1:
			table.add_child(label("%d" % CourseContext.current_course_descriptor.par_total, Color.YELLOW))
		else:
			table.add_child(label("%d" % (holes[column - 1] as HoleDescriptor).hole_par, Color.YELLOW))

func on_player_spawn(player : Player) -> void:
	var player_score = CourseContext.get_score_by_player_id(player.player_id)
	if not player_score:
		player_score = PlayerScore.create(player.player_id, player.player_name, player.player_color, CourseContext.current_course_descriptor)
		CourseContext.set_score(player_score)
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
			table.add_child(label(("%d" % scores[column - 1]) if column - 1 < CourseContext.hole_index else "-", Color.WHITE if column - 1 == CourseContext.hole_index else Color.DIM_GRAY))

func remove_row_for_player(player_score : PlayerScore) -> void:
	var column_count = player_score.scores.size() + 2

	var start_index = -1
	for i in table.get_children().size():
		var child = table.get_child(i) as Label
		var target_label_name = str(player_score.player_id) if player_score.player_id != 1 else "server"
		if child.name == target_label_name:
			start_index = child.get_index()
			break
	for column in range(column_count):
		var child = table.get_child(column + start_index)
		child.queue_free()

func on_player_score_updated(score : PlayerScore) -> void:
	update_score_table_for_player(score)

func update_score_table_for_player(score : PlayerScore) -> void:
	var start_index = -1
	var player_id = score.player_id
	for child : Label in table.get_children():
		var target_label_name = str(player_id) if player_id != 1 else "server"
		if child.name == target_label_name:
			start_index = child.get_index()
			break
	# add one to offset player name
	var hole_index = CourseContext.hole_index
	var hole_to_update = table.get_child(start_index + hole_index + 1) as Label
	hole_to_update.text = str(score.scores[hole_index])

	# update sum
	var sum_index = CourseContext.current_course_descriptor.holes.size()
	var sum_to_update = table.get_child(start_index + sum_index + 1) as Label
	sum_to_update.text = str(score.sum())

func on_player_disconnected(player_id : int, _player_name : String) -> void:
	remove_row_for_player(CourseContext.get_score_by_player_id(player_id))

func on_game_proceeding() -> void:
	show_score_regardless = true

func label(text : String, color : Color = Color.WHITE) -> Label:
	var new_label = Label.new()
	new_label.text = text
	new_label.modulate = color
	new_label.name = str(table.get_children().size())
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	return new_label
