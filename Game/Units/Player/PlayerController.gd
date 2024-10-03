class_name PlayerController extends UnitController
# Extending from the Unit Controller to works as a brain
# Will literally control the Unit based on inputs

@export_group("COMPONENTS")
@export var goop : GoopController

@export_group("INPUTS")
@export var leftInput : InputAction
@export var rightInput : InputAction
@export var upInput : InputAction
@export var downInput : InputAction
@export var mainActionInput : InputAction
@export var dropInput : InputAction
@export var dashInput : InputAction

@export_group("DASH")
@export var _dashSpeed := 700.0
@export var _dashCooldown := 5.0
@export var _dash_stretch = 1.5
@export var _dash_cost = 5
var _is_dashing := false
var _can_dash := true

var _motion := Vector2.ZERO
var _last_motion := Vector2.RIGHT
var _last_aim := Vector2.ZERO

func _enter_tree():
	GameManager.Player = self

func _physics_process(delta: float) -> void:
	if mainActionInput.is_pressed :
		TryMainAction()
	
	super._physics_process(delta)

# INPUTS
func GetMoveDirection():
	if _is_dashing:
		return _last_motion # Keep going in the same direction
	
	_motion = Vector2.ZERO
	
	if leftInput.is_pressed :
		_motion.x -= 1
	
	if rightInput.is_pressed :
		_motion.x += 1
	
	if upInput.is_pressed :
		_motion.y -= 1
	
	if downInput.is_pressed :
		_motion.y += 1
	
	_motion = _motion.normalized()
	
	if _motion != Vector2.ZERO:
		_last_motion = _motion
	
	return _motion

func GetAimDirection():
	if _is_dashing:
		return _last_motion + global_position
	
	# TODO: Make it use input instead of just mouse
	_last_aim = get_global_mouse_position()
	return _last_aim

# SIGNALS
func _on_drop_action_on_input_press():
	TryDropAction()

func _on_health_hit(attacker, health):
	TinyUtils.set_time_scale(0.05, 1.15)
	CameraManager.Shake(10, 0.15)

func _on_dash_action_on_input_press():
	if _is_dashing or not _can_dash or not canMove or _Is_Impulsed():
		return
	
	_is_dashing = true
	_can_dash = false
	goop.reduce(_dash_cost)
	ApplyImpulse(_last_motion, _dashSpeed)
	var ogScale = bodyNode.scale
	bodyNode.scale = Vector2(_dash_stretch, ogScale.y)
	await get_tree().create_tween().tween_property(
		bodyNode, "scale", ogScale, _current_impulse_duration).finished
	_is_dashing = false
	print("Started dash cooldown")
	await get_tree().create_timer(_dashCooldown).timeout
	print("Completed dash cooldown")
	_can_dash = true
