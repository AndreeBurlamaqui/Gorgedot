extends CanvasLayer

@export var _goop_bar : ProgressBar
@export var _dash_bar : ProgressBar
@export var _consume_bar : ProgressBar
@export var _score_label : Label

func _ready():
	GameManager.Player.goop.on_update.connect(_on_goop_update)
	GameManager.Player.dash.connect(_on_dash)
	GameManager.Player.enemies_consumable_changed.connect(_on_enemies_to_consume_chaged)
	GameManager.Player.consuming_enemy.connect(_on_enemy_consumed)
	GameManager.score_changed.connect(_on_score_changed)
	_on_score_changed (0)
	_on_goop_update(GameManager.Player.goop._max_goop, GameManager.Player.goop.cur_goop)
	_dash_bar.min_value = 0
	_dash_bar.max_value = 1
	_consume_bar.value = 1
	_consume_bar.max_value = 1
	_consume_bar.min_value = 0
	_consume_bar.value = 0

func free():
	GameManager.Player.goop.on_update.disconnect(_on_goop_update)

func _on_goop_update(max : float, current : float):
	_goop_bar.max_value = max
	_goop_bar.min_value = 0
	_goop_bar.value = current
	print("Updating goop bar {0}/{1}".format([current, max]))

func _on_dash():
	_dash_bar.value = 0
	_dash_bar.scale = Vector2.ONE * 0.75
	var feedback_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT_IN)
	var dash_cd = GameManager.Player._dashCooldown
	feedback_tween.tween_property(_dash_bar, "value", 1, dash_cd)
	feedback_tween.tween_property(_dash_bar, "scale", Vector2.ONE, dash_cd * 0.75)

func _on_enemies_to_consume_chaged(enemies : Array[Health]) :
	# Fill only when there are enemies to consume
	print("enemies to consume: " , enemies.size())
	_consume_bar.value = TinyMath.pick(enemies.is_empty(), 0, 1)

func _on_enemy_consumed() :
	_consume_bar.scale = Vector2.ONE * 0.75
	create_tween().tween_property(_consume_bar, "scale", Vector2.ONE, 0.15)

func _on_score_changed(newScore : int) :
	_score_label.text = str(newScore).pad_zeros(10)
