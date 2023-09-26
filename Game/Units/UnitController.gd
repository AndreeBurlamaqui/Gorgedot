class_name UnitController
extends CharacterBody2D

@export var moveSpeed := 500.0
@export var moveAcceleration := 1500.0
@export var moveFriction := 2500.0
@export var leftInput : InputEventAction
@export var rightInput : InputEventAction
@export var upInput : InputEventAction
@export var downInput : InputEventAction
@export var mainActionInput : InputEventAction

@export var currentWeapon : WeaponBase

var tryMainAct = false

func _physics_process(delta):
	var moveDirection = GetMoveInput()
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
	
	move_and_slide()
	
	# Rotate towards aim
	look_at(GetAimInput())
	
		# Try to act after look_at so the direction is correct
	if tryMainAct:
		TryMainAction()

func _unhandled_input(event):
	if event.is_action_pressed(mainActionInput.action):
		tryMainAct = true
	
	if event.is_action_released(mainActionInput.action):
		tryMainAct = false

func GetMoveInput():
	var motion = Vector2()
	if Input.is_action_pressed(leftInput.action):
		motion.x -= 1
	
	if Input.is_action_pressed(rightInput.action):
		motion.x += 1
	
	if Input.is_action_pressed(upInput.action):
		motion.y -= 1
	
	if Input.is_action_pressed(downInput.action):
		motion.y += 1
	
	return motion.normalized()

func GetAimInput():
	# TODO: Make it use input instead of just mouse
	return get_global_mouse_position()

func TryMainAction():
	if currentWeapon == null:
		return
	
	currentWeapon.TryUse(self)
