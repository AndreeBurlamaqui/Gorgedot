extends WeaponBase
class_name WeaponMelee

@export var comboAnimation : Array[String] = []
@export var impulseForce := 1

var isAttacking := false
var attackCount := 0

func _ready() -> void:
	super._ready()
	animator.stop()

func TryUse(user : UnitController):
	# Check if can do the main action
	if !cooldownTimer.is_stopped():
		return
	
	if isAttacking || animator.is_playing():
		return
	
	isAttacking = true
	user.canAim = false
	user.canMove = false
	PlayAnimation(comboAnimation[attackCount % comboAnimation.size()])
	user.ApplyImpulse(TinyMath.rotation_to_direction(user.rotation), impulseForce)
	
	await animator.animation_finished
	if user != null:
		user.canMove = true
		user.canAim = true
	
	isAttacking = false
	
	# Cooldown to attack again
	cooldownTimer.start()
	await cooldownTimer.timeout
	
	attackCount += 1

func TryThrow(user : UnitController):
	while isAttacking: # Some sort of "queue" the input
		await get_tree().process_frame
	
	super.TryThrow(user)

func Reset():
	attackCount = 0
	isAttacking = false
	
