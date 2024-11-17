extends WeaponBase
class_name WeaponRanged

@export var projectiles : Array[ProjectileData] = []
@export var weaponTip : Node2D

func _ready() -> void:
	super._ready()

func TryUse(user : UnitController) -> bool :
	# Check if can do the main action
	if !cooldownTimer.is_stopped() or !_buildupTimer.is_stopped():
		return false
	
	# Instantiate the current projectile towards aim/unit rotation
	if projectiles.size() <= 0:
		return false
	
	_on_use_weapon(user)
	return true

func _on_use_weapon(user : UnitController) :
	await _await_buildup(user)
	
	for proj in projectiles:
		proj.Shoot(self, unitOwner)
	
	attackCount += 1
