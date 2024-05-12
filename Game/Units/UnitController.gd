class_name UnitController extends CharacterBody2D

@export_group("MOVEMENT")
@export var moveSpeed := 500.0
@export var moveAcceleration := 1500.0
@export var moveFriction := 2500.0

@export_group("WEAPON")
@export var currentWeapon : WeaponBase

@export_group("HEALTH")
@export var stunTimer : Timer

@export_group("VISUAL")
@export var bodyNode = Sprite2D
@export var bodyVisual = Texture2D
@export var bodyScale = 1.0
@export var handsVisual = Texture2D

var currentAimDirection : Vector2
var canAim := true
var canMove := true

func _enter_tree():
	bodyNode.texture = bodyVisual
	bodyNode.scale = Vector2.ONE * bodyScale

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
	
func _on_hurtbox_on_hit(attacker : Hitbox, health : Health) -> void:
	if health == null or attacker == null or !stunTimer.is_stopped():
		pass
	
	var direction = global_position - attacker.holder.global_position
	ApplyImpulse(direction, attacker.knockback)
	# Block movement for a set time
	canMove = false
	stunTimer.start()
	await stunTimer.timeout
	canMove = true
