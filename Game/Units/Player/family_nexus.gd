class_name Nexus extends Node2D

@export var hp_bar : ProgressBar
@export var max_health = 100
@export var hurtbox : Health

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.Family = self
	reset_health()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset_health():
	hurtbox.maxHealth = max_health
	hp_bar.max_value = max_health
	hp_bar.min_value = 0
	hp_bar.value = max_health

func _on_health_on_hit(attacker : Hitbox, health : Health):
	hp_bar.value = health.curHealth
