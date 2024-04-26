class_name EnemyController extends UnitController

@export var AttackDistance : float
@export var MovementType : EnemyMovement

func GetMoveDirection():
	return MovementType.GetMovement(self)

func GetAimDirection():
	if GameManager.Player == null:
		return Vector2.RIGHT
	
	return global_position + (GameManager.Player.global_position - global_position).normalized()
