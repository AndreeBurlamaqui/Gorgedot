## Follow the player
class_name Chaser extends EnemyMovement

func GetMovement(selfEnemy : EnemyController, target : Node2D) -> Vector2:
	if GameManager.Player == null:
		return Vector2.ZERO
	
	var direction = target.global_position - selfEnemy.global_position
	
	if direction.length() > selfEnemy.AttackDistance:
		return direction
	else:
		return Vector2.ZERO
