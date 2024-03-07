extends CanvasGroup

@onready var title : Label = $ShotsLabel
@onready var shots : Label = $CountLabel
@onready var line : Line2D = $Line2D
@onready var title_position : Vector2 = title.position
@onready var par_position : Vector2 = shots.position

var time_alive = 0

func _ready():
	Events.connect(Events.ball_shot.get_name(), update_count)
	Events.connect(Events.ball_sunk.get_name(), lock_count)

func _process(delta: float) -> void:
	time_alive += delta
	title.position.y = title_position.y + 3 * sin(time_alive * 2)
	shots.position.y = par_position.y + 3 * cos(time_alive * 2)
	scale = Vector2(0.975 + 0.025 * scale.x * sin(time_alive * 1.5) * sin(time_alive * 6), 0.975 + 0.025 * scale.y * cos(time_alive * 6) * cos(time_alive * 1.5))

func update_count(ball : Ball):
	shots.text = str(ball.times_hit)

func lock_count(ball : Ball):
	line.modulate = Color(0, 1, 0, 1)
	shots.modulate = Color(0, 1, 0, 1)
