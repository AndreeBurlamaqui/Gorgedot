class_name ProjectileController
extends Node2D

@export_group("COMPONENTS")
@export var timer : Timer
@export var hitBox : Area2D
@export var impactBox : Area2D

@export_group("VALUES")
@export var speed := 250.0
@export var lifetime := 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	
	# Create timer to self-destruct
	timer.timeout.connect(OnDestroy)
	timer.start(lifetime)
	
	# Destroy on impact
	impactBox.body_entered.connect(OnImpact)

func _physics_process(delta):
	global_position += Vector2.RIGHT.rotated(rotation) * speed * delta

func OnDestroy():
	queue_free()

func OnImpact(collision : Node):
	OnDestroy()
