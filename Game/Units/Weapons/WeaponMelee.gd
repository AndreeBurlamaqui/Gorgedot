extends WeaponBase
class_name WeaponMelee

@export var comboAnimation : Array[String] = []
@export var impulseForce := 1

var isAttacking := false

func _ready() -> void:
	super._ready()
	animator.stop()

func TryUse(user : UnitController):
	# Check if can do the main action
	if !cooldownTimer.is_stopped() or !_buildupTimer.is_stopped():
		return false
	
	if isAttacking || animator.is_playing():
		return false
	
	_on_use_weapon(user)
	return true

func TryThrow(user : UnitController):
	while isAttacking: # Some sort of "queue" the input
		await get_tree().process_frame
	
	super.TryThrow(user)

func Reset():
	isAttacking = false

func _on_use_weapon(user : UnitController) :
	isAttacking = true
	user.canAim = false
	user.canMove = false
	
	await _await_buildup(user)
	
	PlayAnimation(comboAnimation[attackCount % comboAnimation.size()])
	if user != null:
		user.ApplyImpulse(TinyMath.rotation_to_direction(user.rotation), impulseForce)
	
	await animator.animation_finished
	if user != null:
		user.canMove = true
		user.canAim = true
	
	isAttacking = false
	attackCount += 1
