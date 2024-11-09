class_name WeaponBase extends Node2D

@export_group("COMPONENTS")
@export var weaponHolder : Node2D 
@export var cooldownTimer : Timer
@export var pickupArea : Area2D
@export var dropRaycast : RayCast2D
@export var animator : AnimationPlayer

@export_group("VALUES")
@export var dropForce = 500.0;
@export var dropSpeed = 750;
@export var attack_distance := 125.0

@export_group("ANIMATIONS")
@export var onPickAnimation : String
@export var onDropAnimation : String
@export var handSprites : Array[Sprite2D] = []

var unitOwner : UnitController

func _enter_tree():
	var hasInitOwner = unitOwner != null
	for hand in handSprites:
		hand.visible = hasInitOwner

func _ready():
	if dropRaycast != null:
		dropRaycast.target_position = Vector2(0, -dropForce)
		dropRaycast.enabled = false
	else:
		print("Null drop raycast on ", name)
	Reset()

func Reset():
	pass

func TryUse(user : UnitController):
	pass

func TryPickup(user : UnitController):
	if unitOwner != null || user.currentWeapon != null:
		return
	
	unitOwner = user
	unitOwner.currentWeapon = self
	SetPickable(false)
	self.get_parent().remove_child(self)
	unitOwner.add_child(self)
	var pickTween = create_tween()
	global_position = unitOwner.global_position
	rotation_degrees = 90 # Default face upwards
	weaponHolder.rotation = 0
	
	# Setup hands
	for hand in handSprites:
		var handSprite = user.handsVisual
		hand.visible = handSprite != null
		hand.texture = handSprite
	
	# Finish animations
	PlayAnimation(onPickAnimation)
	Reset()

func _on_area_2d_body_entered(body: UnitController):
	if body is UnitController:
		call_deferred("TryPickup", body)
	else:
		print("Picker isn't an Unit")

func TryThrow(user : UnitController):
	if user.currentWeapon == null || user.currentWeapon != self :
		return
	
	# Drop the item by applying a bit of force
	# towards the raycast drop
	dropRaycast.enabled = true
	# Raycast always need to look towards the unit's current aim
	weaponHolder.look_at(user.currentAimDirection)
	weaponHolder.rotation += PI/2  # Adjust for sprite facing upwards
	force_update_transform()
	dropRaycast.force_raycast_update()
	TinyUtils.visualize_raycast(dropRaycast, 0.5, Color.RED)
#	print("User rot: ", user.global_rotation, "\n Raycast rot: ", dropRaycast.global_rotation)
	
	# We first check if the raycast hit something to get its end point
	var oldPosition = global_position
	var oldRotation = weaponHolder.global_rotation
	weaponHolder.position = Vector2.ZERO # Reset weapon root
	var end_point = TinyUtils.get_end_point(dropRaycast)
#	TinyUtils.visualize_raycast(dropRaycast, 0.5, Color.YELLOW)
#	print("End point of drop raycast is", end_point)
	
	Drop(user, oldPosition, oldRotation)
	
	# And then tween towards the end point
	SetPickable(false) # Drop sets to true, we need it false while traveling
	var dropTween = create_tween()
	dropTween.set_ease(Tween.EASE_OUT)
	dropTween.set_trans(Tween.TRANS_SINE)
	var dropDuration = oldPosition.distance_to(end_point) / dropSpeed
	dropTween.tween_property(self, "position", end_point, dropDuration).from(oldPosition)
	await dropTween.finished
	# Enable pickable again
	SetPickable(true)
	# Stop animation with keep state for the rotation of the animation
	animator.stop(true)
	PlayAnimation("RESET")
	Reset()

func SetPickable(canPick : bool):
	pickupArea.monitoring = canPick

func PlayAnimation(targetAnimation : String):
	if targetAnimation == null || targetAnimation.is_empty():
		return
	
	animator.play(targetAnimation)

func Drop(user : UnitController, dropPos : Vector2, dropRot : float):
	# And then clean the current weapon from the unit
	user.currentWeapon = null
	unitOwner = null
	
	# Remove weapon as a child from the unit
	var currentSceneRoot = get_tree().current_scene 
	self.get_parent().remove_child(self)
	currentSceneRoot.add_child(self)
	global_position = dropPos
	global_rotation = dropRot
	PlayAnimation(onDropAnimation)
	
	SetPickable(true) # Enable pickable again
	
	PlayAnimation("RESET")
	Reset()
