class_name PlayerController extends UnitController
# Extending from the Unit Controller to works as a brain
# Will literally control the Unit based on inputs

@export_group("INPUTS")
@export var leftInput : InputAction
@export var rightInput : InputAction
@export var upInput : InputAction
@export var downInput : InputAction
@export var mainActionInput : InputAction
@export var dropInput : InputAction

func _ready() -> void:
	GameManager.Player = self

func _physics_process(delta: float) -> void:
	if mainActionInput.is_pressed :
		TryMainAction()
		
	super._physics_process(delta)

func GetMoveDirection():
	var motion = Vector2()
	
	if leftInput.is_pressed :
		motion.x -= 1
	
	if rightInput.is_pressed :
		motion.x += 1
	
	if upInput.is_pressed :
		motion.y -= 1
	
	if downInput.is_pressed :
		motion.y += 1
	
	return motion.normalized()

func GetAimDirection():
	# TODO: Make it use input instead of just mouse
	return get_global_mouse_position()

func _on_drop_action_on_input_press():
	TryDropAction()
