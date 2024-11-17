class_name EnemyController extends UnitController

@export var MovementType : EnemyMovement

@export_group("ATTACK")
@export var focusArea : Area2D
var _focusTarget : Node2D # Just to get the direction mostly
var _targetOffset := Vector2.ONE * 2

@export var _flash_animations : AnimationPlayer

func _enter_tree():
	# Should not hit enemy (6)
	# And hit player (5), nexus (7) and damageables (2)
	damage_matrix = [
		[6 , false],
		[2 , true],
		[5 , true],
		[7 , true],
	]

func _ready():
	focusArea.area_entered.connect(on_enter_focus_area)
	focusArea.area_exited.connect(on_exit_focus_area)

	_set_focus_target(GameManager.Family)
	_flash_animations.play(&"RESET")

func GetMoveDirection():
	return MovementType.GetMovement(self, _get_focus_target_position())

func GetAimDirection():
	if _focusTarget == null:
		return Vector2.RIGHT
	
	return global_position + (_focusTarget.global_position - global_position).normalized()


func _on_health_hit(attacker, health : Health):
	TinyUtils.set_time_scale(0.15, 0.5)
	
	if health.curHealth <= 0 :
		GameManager.add_score(health.maxHealth)
		if currentWeapon != null :
			currentWeapon.Drop(self, global_position, global_rotation)
	
	var can_player_consume_self = GameManager.Player.can_consume(health)
	await play_and_reset_flash("hit")
	if can_player_consume_self :
		play_and_reset_flash("can_consume_flash")
	

func on_enter_focus_area(collision : Area2D):
	# On entering the focus area
	# The enemy needs to start attacking it,
	# instead of focusing the nexus
	_set_focus_target(collision)

func on_exit_focus_area(collision : Area2D):
	# On exiting, if its the player
	# The enemy needs to go back focusing the nexus
	_set_focus_target(GameManager.Family)

func _process(delta):
	if MovementType.GetMovement(self, _get_focus_target_position()).length() < GetAttackDistance() :
		TryMainAction()
	
	super._process(delta)

func play_and_reset_flash(animName : String) -> Signal:
	_flash_animations.play(animName)
	await _flash_animations.animation_finished
	_flash_animations.play(&"RESET")
	return get_tree().process_frame

func GetAttackDistance() -> float :
	var atkDist = 0.0
	if currentWeapon != null :
		atkDist = currentWeapon.attack_distance 
	
	return atkDist

func _get_focus_target_position() -> Vector2 :
	# Based on the offset, return the position to go towards
	var focusPos = _focusTarget.global_position + _targetOffset
	# TinyUtils.visualize_circle(get_tree(), focusPos, 1, 0.1, Color.WHITE)
	return focusPos

func _set_focus_target(newTarget):
	_focusTarget = newTarget
	# Set the offset that it'll try to search to
	# This will make the enemies to be a bit different from each other
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var random_magnitude = randf_range(1, GetAttackDistance())
	_targetOffset = random_direction * random_magnitude
