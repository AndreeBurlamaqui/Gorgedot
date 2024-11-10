extends CanvasLayer

@export var _goop_bar : ProgressBar
@export var _dash_bar : ProgressBar
@export var _consume_bar : ProgressBar
@export var _score_label : Label
@export var _game_over_screen : Control

@export_group("STOMACH")
@export var _stomach_parent : Array[Control]
@export var _stomach_weapons : Array[TextureRect]
@export var _stomach_durabilities : Array[ProgressBar]
@export var _stomach_gradient : Gradient

func _ready():
	GameManager.Player.goop.on_update.connect(_on_goop_update)
	GameManager.Player.dash.connect(_on_dash)
	GameManager.Player.enemies_consumable_changed.connect(_on_enemies_to_consume_chaged)
	GameManager.Player.consuming_enemy.connect(_on_enemy_consumed)
	GameManager.Player.stomach_updated.connect(_on_stomach_update)
	
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_ended.connect(_on_game_ended)
	_on_score_changed (0)
	_on_goop_update(GameManager.Player.goop._max_goop, GameManager.Player.goop.cur_goop)
	_dash_bar.min_value = 0
	_dash_bar.max_value = 1
	_consume_bar.value = 1
	_consume_bar.max_value = 1
	_consume_bar.min_value = 0
	_consume_bar.value = 0
	_game_over_screen.visible = false

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

func _on_game_ended(state : GameManager.GameState):
	process_mode = Node.PROCESS_MODE_ALWAYS
	_game_over_screen.visible = true

func _on_restart_click() :
	GameManager.restart_game()

func _on_stomach_update(curWeapon : WeaponBase, stomach : Array[WeaponBase]) :
	# Middle one will be the cur weapon
	var curSlot = _stomach_weapons[1]
	var curProgress = _stomach_durabilities[1]
	if curWeapon == null or not is_instance_valid(curWeapon):
		curSlot.visible = false
		_stomach_parent[1].modulate = Color.WHITE
		curProgress.value = 0
	else :
		curSlot.visible = true
		curSlot.texture = curWeapon.visual.texture
		curProgress.max_value = curWeapon.max_durability
		curProgress.min_value = 0
		curProgress.value = curWeapon.durability
		var curColor = inverse_lerp(curWeapon.max_durability, 0, curWeapon.durability)
		_stomach_parent[1].modulate = _stomach_gradient.sample(curColor)
	
	# Other 2 will be from stomach
	var qWeapon = stomach[0]
	var qSlot = _stomach_weapons[0]
	var qProgress = _stomach_durabilities[0]
	if qWeapon == null:
		# Hide slot
		qSlot.visible = false
		_stomach_parent[0].modulate = Color.WHITE
		qProgress.value = 0
	else :
		qSlot.visible = true
		qSlot.texture = qWeapon.visual.texture
		qProgress.max_value = qWeapon.max_durability
		qProgress.min_value = 0
		qProgress.value = qWeapon.durability
		var curColor = inverse_lerp(qWeapon.max_durability, 0, qWeapon.durability)
		_stomach_parent[0].modulate = _stomach_gradient.sample(curColor)
	
	var eWeapon = stomach[1]
	var eSlot = _stomach_weapons[2]
	var eProgress = _stomach_durabilities[2]
	if eWeapon == null:
		eSlot.visible = false
		_stomach_parent[2].modulate = Color.WHITE
		eProgress.value = 0
	else :
		eSlot.visible = true
		eSlot.texture = eWeapon.visual.texture
		eProgress.max_value = eWeapon.max_durability
		eProgress.min_value = 0
		eProgress.value = eWeapon.durability
		var curColor = inverse_lerp(eWeapon.max_durability, 0, eWeapon.durability)
		_stomach_parent[2].modulate = _stomach_gradient.sample(curColor)
