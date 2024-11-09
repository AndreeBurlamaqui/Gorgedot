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
var _last_impulse_force := Vector2.ZERO
var _current_impulse_duration := 0.0
var _last_impulse_duration := 0.0

var damage_matrix = [0 , false]

func _enter_tree():
	bodyNode.texture = bodyVisual
	bodyNode.scale = Vector2.ONE * bodyScale

func _process(delta):
	# Rotate towards aim
	if canAim:
		currentAimDirection = GetAimDirection()
		look_at(currentAimDirection)

func _physics_process(delta):
	if _Is_Impulsed() :
		var impulse_factor = ease(_current_impulse_duration / _last_impulse_duration, 0.25)
		velocity = _last_impulse_force * delta * 50 * impulse_factor
		_current_impulse_duration -= delta
	else :
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
	
	currentWeapon.TryThrow(self)

func ApplyImpulse(direction : Vector2, force : float):
	if _Is_Impulsed():
		return
	
	# Based on force, create a duration
	_last_impulse_duration = force * 0.00005
	_current_impulse_duration = _last_impulse_duration
	# Keep a specific velocity during this duration
	_last_impulse_force = direction.normalized() * force
	print(" {0} unit getting impulsed by {1} for {2} seconds".format([name, force, _last_impulse_duration]))

func _Is_Impulsed() -> bool:
	return _current_impulse_duration > 0

func _on_hurtbox_on_hit(attacker : Hitbox, health : Health) -> void:
	if health == null or attacker == null or !stunTimer.is_stopped():
		return
	
	#if is_queued_for_deletion() or attacker.is_queued_for_deletion() :
	#	return
	
	# print(name, " unit getting hit")
	var direction = global_position - attacker.holder.global_position
	ApplyImpulse(direction.normalized(), attacker.knockback)
	# Block movement for a set time
	canMove = false
	stunTimer.start()
	await stunTimer.timeout
	canMove = true

func on_weapon_pick(newWeapon : WeaponBase):
	# Setup hands
	for hand in newWeapon.handSprites:
		var handSprite = handsVisual
		hand.visible = handSprite != null
		hand.texture = handSprite
	
	# Change collision matrix
	for child in TinyUtils.get_all_children(newWeapon):
		if child is Hitbox:
			for dmgCol in damage_matrix:
				child.set_collision_mask_value(dmgCol[0], dmgCol[1])
