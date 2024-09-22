extends Node2D

@export var enemy : PackedScene
@export var weapons : Array[PackedScene] = []
@export var camera : Camera2D
@export var startEnemyCount = 1
@export var difficultyCurve : Curve
@export var startDelay = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	wave_loop()

func wave_loop():
	while (GameManager.Family.hurtbox.curHealth > 0):
		# Restart timer based on difficulty curve
		var nextWave = startDelay
		await get_tree().create_timer(nextWave).timeout
		# Spawn new enemies, amount based on difficulty curve
		var viewport_size = get_viewport_rect().size
		var top_left = camera.get_screen_center_position() - viewport_size / 2
		var visible_area = Vector2(viewport_size.x, viewport_size.y)
		for s in startEnemyCount:
			var newEnemy : Node2D = enemy.instantiate()
			var newWeapon : Node2D = weapons.pick_random().instantiate()
			var spawnPos = TinyUtils.get_random_position_outside(global_position, visible_area, 25)
			newEnemy.global_position = spawnPos
			newWeapon.global_position = spawnPos
			add_child(newEnemy)
			add_child(newWeapon)

