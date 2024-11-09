class_name ProjectileData extends Resource 

@export var projectile : PackedScene
@export var damage := 0.0
@export var amount : float = 1.0
@export var angle := Vector2(0,0)
@export var randomAngle := false

func Shoot(weapon : WeaponRanged, user : UnitController):
	if projectile == null:
		return
	
	for i in amount:
		var newProj = projectile.instantiate() as ProjectileController
		
		# Prepare position and look at
		newProj.position = weapon.weaponTip.global_position
		# print("lerp is ", "i: ", i, " and amount: ", amount, " == ", i/amount)
		var projAngle = TinyMath.pick(randomAngle, randf_range(angle.x, angle.y), lerpf(angle.x, angle.y, i/amount))
		newProj.rotation = user.global_rotation + deg_to_rad(projAngle)
		
		# Change collision based on what the weapon is damaging
		for child in TinyUtils.get_all_children(newProj):
			if child is Hitbox:
				for dmgCol in user.damage_matrix:
					child.set_collision_mask_value(dmgCol[0], dmgCol[1])
					newProj.impactBox.set_collision_mask_value(dmgCol[0], dmgCol[1])
		
		# Spawn
		user.get_tree().root.add_child(newProj)
		# TinyUtils.visualize_angle(weapon.weaponTip, angle, 0.5, Color.DARK_GOLDENROD)
