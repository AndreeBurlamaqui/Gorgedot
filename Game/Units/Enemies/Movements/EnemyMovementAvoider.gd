## Avoid the player
extends EnemyMovement

func GetMovement(selfEnemy : EnemyController, target : Node2D) -> Vector2:
	return Vector2.UP
