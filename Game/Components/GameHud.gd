extends CanvasLayer

@export var _goop_bar : ProgressBar
@export var _dash_bar : ProgressBar
@export var _consume_bar : ProgressBar

func _ready():
	GameManager.Player.goop.on_update.connect(_on_goop_update)
	_on_goop_update(GameManager.Player.goop._max_goop, GameManager.Player.goop.cur_goop)
	_dash_bar.min_value = 0
	_dash_bar.max_value = 1
	GameManager.Player.dash.connect(_on_dash)

func free():
	GameManager.Player.goop.on_update.disconnect(_on_goop_update)

func _on_goop_update(max : float, current : float):
	_goop_bar.max_value = max
	_goop_bar.min_value = 0
	_goop_bar.value = current
	print("Updating goop bar {0}/{1}".format([current, max]))

func _on_dash():
	_dash_bar.value = 0
	var feedback_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT_IN)
	var dash_cd = GameManager.Player._dashCooldown
	feedback_tween.tween_property(_dash_bar, "value", 1, dash_cd)
	feedback_tween.tween_property(_dash_bar, "scale", Vector2.ONE * 0.75, dash_cd * 0.75)
	await  feedback_tween.finished
	_dash_bar.scale = Vector2.ONE
