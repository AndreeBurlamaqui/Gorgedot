## Avoid the player
extends EnemyMovement

func GetMovement(selfEnemy : EnemyController) -> Vector2:
	return Vector2.UP
