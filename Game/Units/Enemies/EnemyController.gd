class_name EnemyController extends UnitController

@export var AttackDistance : float = 200.0:
	set(value):
		AttackDistance = value
		queue_redraw()
@export var MovementType : EnemyMovement

@export_group("ATTACK")
@export var focusArea : Area2D
var focusTarget : Node2D # Just to get the direction mostly

@export var _flash_animations : AnimationPlayer

func _ready():
	focusArea.area_entered.connect(on_enter_focus_area)
	focusArea.area_exited.connect(on_exit_focus_area)

	focusTarget = GameManager.Family

func GetMoveDirection():
	return MovementType.GetMovement(self, focusTarget)

func GetAimDirection():
	if focusTarget == null:
		return Vector2.RIGHT
	
	return global_position + (focusTarget.global_position - global_position).normalized()


func _on_health_hit(attacker, health : Health):
	TinyUtils.set_time_scale(0.15, 0.5)
	await play_and_reset_flash("hit")
	if GameManager.Player.can_consume(health) :
		play_and_reset_flash("can_consume_flash")

func on_enter_focus_area(collision : Area2D):
	# On entering the focus area
	# The enemy needs to start attacking it,
	# instead of focusing the nexus
	focusTarget = collision

func on_exit_focus_area(collision : Area2D):
	# On exiting, if its the player
	# The enemy needs to go back focusing the nexus
	focusTarget = GameManager.Family

func _process(delta):
	if MovementType.GetMovement(self, focusTarget).length() < AttackDistance :
		TryMainAction()
	
	super._process(delta)

func play_and_reset_flash(animName : String) -> Signal:
	_flash_animations.play(animName)
	await _flash_animations.animation_finished
	_flash_animations.play(&"RESET")
	return get_tree().process_frame
