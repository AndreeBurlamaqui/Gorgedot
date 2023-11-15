extends WeaponBase

var isAttacking := false
var attackCount := 0

func TryUse(user : UnitController):
	if isAttacking:
		return
	
	isAttacking = true
	attackCount += 1
	var atkCountEven = TinyMath.is_even(attackCount)
	var finalRot = -45 if atkCountEven else 225
	var finalPos = positionOnPick
	finalPos.y *= TinyMath.pick(atkCountEven, 1, -1)
	print("final pos is " , finalPos, "based on is even", atkCountEven)
	var swordTween = create_tween()
	swordTween.tween_property(self, "rotation_degrees", finalRot, 0.15)
	var curveSword = do_arc(self, finalPos, 25, 0.25)
#	swordTween.tween_property(self, "rotation", deg_to_rad(rotationOnPick), 0.15)
	await swordTween.finished and curveSword.finished
	
	# Cooldown to attack again
	cooldownTimer.start()
	await cooldownTimer.timeout
	
	isAttacking = false

func Reset():
	attackCount = 0
	isAttacking = false

# TODO: Search on how to make it a static func so we can use anywhere else
func do_arc(node, final_pos, height, duration):
	var tween = create_tween()
	var start_pos = node.position
	var mid_pos = final_pos
	mid_pos.x += height
	
	tween.tween_property(node, "position", mid_pos, duration * 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT).from(start_pos)
	tween.tween_property(node, "position", final_pos, duration * 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
	return tween
