class_name ProjectileController extends Node2D

@export_group("COMPONENTS")
@export var timer : Timer
@export var hitBox : Area2D
@export var impactBox : Area2D
@export var animator : AnimationPlayer

@export_group("VALUES")
@export var speed := 250.0
@export var lifetime := 3.0

@export var hitAnimation : String

var canMove := true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	
	# Create timer to self-destruct
	timer.timeout.connect(OnDestroy)
	timer.start(lifetime)
	
	# Destroy on impact
	impactBox.body_entered.connect(OnImpact)

func _physics_process(delta):
	if canMove :
		global_position += GetDirection() * speed * delta

func GetDirection():
	return Vector2.RIGHT.rotated(rotation)

func OnDestroy():
	queue_free()

func OnImpact(collision : Node):
	animator.play(hitAnimation)
	canMove = false
	await animator.animation_finished
	OnDestroy()
