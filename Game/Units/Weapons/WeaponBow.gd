extends WeaponBase

@export var projectile : PackedScene
@export var weaponTip : Node2D

func TryUse(user : UnitController):
		# Check if can do the main action
	if !cooldownTimer.is_stopped():
		return
	
	# Instantiate the current projectile towards aim/unit rotation
	var newProj = projectile.instantiate()
	newProj.position = weaponTip.global_position
	newProj.rotation = user.global_rotation
	get_tree().root.add_child(newProj)
	
	# Add cooldown
	cooldownTimer.start()
