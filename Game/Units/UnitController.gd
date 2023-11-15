class_name UnitController
extends CharacterBody2D

@export var moveSpeed := 500.0
@export var moveAcceleration := 1500.0
@export var moveFriction := 2500.0

@export var currentWeapon : WeaponBase

var currentAimDirection : Vector2
var canAim := true
var canMove := true

func _physics_process(delta):
	# Calculate movement based on set direction
	var moveDirection = GetMoveDirection()
	if !canMove || moveDirection == Vector2.ZERO:
		# Apply friction
		var frictionAmount = moveFriction * delta
		if velocity.length() > frictionAmount:
			velocity -= velocity.normalized() * frictionAmount
		else:
			velocity = Vector2.ZERO
	else:
		# Apply accelerated movement
		velocity += moveDirection * moveAcceleration * delta
		velocity = velocity.limit_length(moveSpeed)
	
	# Rotate towards aim
	if canAim:
		currentAimDirection = GetAimDirection()
		look_at(currentAimDirection)
	
	move_and_slide()

func GetMoveDirection():
	return Vector2.ZERO

func GetAimDirection():
	return Vector2.RIGHT
	
func TryMainAction():
	if currentWeapon == null:
		return
	
	currentWeapon.TryUse(self)

func TryDropAction():
	if(currentWeapon == null):
		return
	
	currentWeapon.TryDrop(self)

func ApplyImpulse(direction : Vector2, force : float):
	velocity = direction.normalized() * force
	move_and_slide()
