## Avoid the player
extends EnemyMovement

func GetMovement(selfEnemy : EnemyController, target : Vector2) -> Vector2:
	return Vector2.UP
