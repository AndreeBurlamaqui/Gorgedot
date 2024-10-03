extends CanvasLayer

@export var _goop_bar : ProgressBar

func _ready():
	GameManager.Player.goop.on_update.connect(_on_goop_update)
	_on_goop_update(GameManager.Player.goop._max_goop, GameManager.Player.goop.cur_goop)

func free():
	GameManager.Player.goop.on_update.disconnect(_on_goop_update)

func _on_goop_update(max : float, current : float):
	_goop_bar.max_value = max
	_goop_bar.min_value = 0
	_goop_bar.value = current
	print("Updating goop bar {0}/{1}".format([current, max]))
