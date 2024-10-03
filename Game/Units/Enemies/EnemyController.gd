class_name EnemyController extends UnitController

@export var AttackDistance : float = 200.0:
	set(value):
		AttackDistance = value
		queue_redraw()
@export var MovementType : EnemyMovement

@export_group("ATTACK")
@export var focusArea : Area2D
var focusTarget : Node2D # Just to get the direction mostly


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
	if health.curHealth <= 0:
		queue_free()

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

func _draw():
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, AttackDistance, Color(1, 0, 0, 0.3))
