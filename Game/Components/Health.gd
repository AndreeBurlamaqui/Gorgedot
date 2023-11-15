extends Area2D
class_name Health

@export_group("COMPONENTS")
@export var animator : AnimationPlayer

@export_group("VALUES")
@export var maxHealth := 1.0
@export var hurtAnimation := "basic_hurt"

var curHealth : float

# Called when the node enters the scene tree for the first time.
func _ready():
	RestoreHealth(maxHealth)

func RestoreHealth(heal : float):
	curHealth = min(heal, maxHealth) # Clamped by max

func ApplyDamage(damage : float):
	curHealth -= damage
	PlayAnimation(hurtAnimation)
	CheckDeath()

func CheckDeath():
	if curHealth <= 0:
		queue_free()

func PlayAnimation(animName : String):
	if animator == null:
		return
	
	animator.stop()
	animator.play(animName)
