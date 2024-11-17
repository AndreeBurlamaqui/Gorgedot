## Follow the player
class_name Chaser extends EnemyMovement

func GetMovement(selfEnemy : EnemyController, target : Vector2) -> Vector2:
	var direction = target - selfEnemy.global_position
	
	if direction.length() > selfEnemy.GetAttackDistance():
		return direction
	else:
		return Vector2.ZERO
