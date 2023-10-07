class_name InputAction
extends Node

# Custom node to update the target input
# So we can easily get things like:
# "was pressed", "is holding", "time holding"
@export var action_name : String

var is_pressed = false
var time_being_held = 0.0
var is_being_held = false

signal OnInputPress
signal OnInputRelease

func _input(event):
	var justPressed = Input.is_action_pressed(action_name)
	
	if is_pressed && !justPressed :
		OnInputRelease.emit()
	
	if !is_pressed && justPressed :
		OnInputPress.emit()
	
	is_pressed = justPressed

func _process(delta):
	if is_pressed :
		time_being_held += delta
	else :
		time_being_held = 0
	
	is_being_held = time_being_held > 0
