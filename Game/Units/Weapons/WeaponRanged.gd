extends WeaponBase
class_name WeaponRanged

@export var projectiles : Array[ProjectileData] = []
@export var weaponTip : Node2D

func _ready() -> void:
	super._ready()

func TryUse(user : UnitController) -> bool :
	# Check if can do the main action
	if !cooldownTimer.is_stopped():
		return false
	
	# Instantiate the current projectile towards aim/unit rotation
	if projectiles.size() <= 0:
		return false
	
	for proj in projectiles:
		proj.Shoot(self, unitOwner)
	
	# Add cooldown
	cooldownTimer.start()
	return true
