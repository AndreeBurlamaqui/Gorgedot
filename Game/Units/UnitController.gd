class_name UnitController
extends CharacterBody2D

@export var moveSpeed := 500.0
@export var moveAcceleration := 1500.0
@export var moveFriction := 2500.0

@export var currentWeapon : WeaponBase

var currentAimDirection : Vector2

func _physics_process(delta):
	OnStartPhysics(delta)
	
	# Calculate movement based on set direction
	var moveDirection = GetMoveDirection()
	if moveDirection == Vector2.ZERO:
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
	currentAimDirection = GetAimDirection()
	look_at(currentAimDirection)
	
	move_and_slide()
	
	OnFinishPhysics(delta)

func GetMoveDirection():
	return Vector2.ZERO.normalized()

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

# In case we want to display or do something 
# only before the physics are processed
func OnStartPhysics(delta : float):
	pass

# In case we want to display or do something 
# only after the physics are processed
func OnFinishPhysics(delta : float):
	pass
