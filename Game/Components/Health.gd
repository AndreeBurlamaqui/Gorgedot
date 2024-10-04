class_name Health extends Area2D

@export_group("COMPONENTS")
@export var parent : Node
@export var animator : AnimationPlayer

@export_group("VALUES")
@export var maxHealth := 1.0
@export var hurtAnimation := "basic_hurt"

var curHealth : float

signal on_hit (attacker : Hitbox, health : Health)
signal on_death

# Called when the node enters the scene tree for the first time.
func _ready():
	RestoreHealth(maxHealth)

func RestoreHealth(heal : float):
	curHealth = min(heal, maxHealth) # Clamped by max

func ApplyDamage(attacker : Hitbox, damage : float):
	print("Getting hit by ", damage)
	curHealth -= damage
	on_hit.emit(attacker, self)
	PlayAnimation(hurtAnimation)
	CheckDeath()

func CheckDeath():
	if curHealth <= 0:
		on_death.emit()
		if parent != null :
			parent.queue_free()

func PlayAnimation(animName : String):
	if animator == null:
		return
	
	animator.stop()
	animator.play(animName)
