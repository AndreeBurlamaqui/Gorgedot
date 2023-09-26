class_name WeaponBase
extends Sprite2D

@export var cooldownTimer : Timer
@export var pickupArea : Area2D

var unitOwner : UnitController

func TryUse(user : UnitController):
	pass

func TryPickup(user : UnitController):
	if unitOwner != null:
		return
	
	unitOwner = user
	pickupArea.monitorable = false
	self.get_parent().remove_child(self)
	unitOwner.add_child(self)
	global_position = unitOwner.global_position
	unitOwner.currentWeapon = self

func _on_area_2d_body_entered(body: UnitController):
	if body is UnitController:
		call_deferred("TryPickup", body)
	else:
		print("Picker isn't an Unit")
