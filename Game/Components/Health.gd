class_name Health
extends Area2D

@export var maxHealth := 1.0

var curHealth

# Called when the node enters the scene tree for the first time.
func _ready():
	RestoreHealth(maxHealth)

func RestoreHealth(heal : float):
	curHealth = min(heal, maxHealth) # Clamped by max

func ApplyDamage(damage : float):
	curHealth -= damage
	CheckDeath()

func CheckDeath():
	if curHealth <= 0:
		queue_free()
