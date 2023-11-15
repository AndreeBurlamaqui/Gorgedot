extends Area2D
class_name Hitbox
# Hitboxes will only search for Health components

@export var damage := 0

var collisionShape : CollisionShape2D

func _init():
	# Hitboxes don't need to be monitorable
	# They'll only monitore
	self.monitorable = false

func _ready() -> void:
	area_entered.connect(OnHit)
	
	# Store collision shape so I can disable it later
	for child in get_children():
		if child is CollisionShape2D:
			print("Getting collision shape child")
			collisionShape = child

func OnHit(hurtBox : Health):
	if hurtBox == null:
		return
	
	hurtBox.ApplyDamage(damage)

func SetActive(newState : bool):
	monitoring = newState
	collisionShape.disabled = !newState
