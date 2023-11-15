extends ProjectileController

@export var rotationSpeed := 1
var currentDirection := Vector2()

func _ready() -> void:
	super._ready()
	currentDirection = GetDirection()

func _physics_process(delta):
	if !canMove:
		return
	
	currentDirection = currentDirection.rotated(rotationSpeed * delta)
	position += currentDirection * speed * delta

