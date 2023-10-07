class_name Hitbox
extends Area2D
# Hitboxes will only search for Health components

@export var damage := 0

func _init():
	# Hitboxes don't need to be monitorable
	# They'll only monitore (?)
	self.monitorable = false

