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
@export var consumeInput : InputAction

@export_group("DASH")
@export var _dashSpeed := 700.0
@export var _dashCooldown := 5.0
@export var _dash_stretch = 1.5
@export var _dash_cost = 5
var _is_dashing := false
var _can_dash := true
signal dash

@export_group("CONSUME")
@export_range(0, 1, 0.05) var _consume_threshold := 0.15 # In percent
@export var _consume_area := 250
@export var _consume_cooldown := 0.75
@export var _consume_recover = 5.0
var _is_consuming := false
var _is_checking_consume := false
var _possible_enemies_consumable : Array[Health]
signal enemies_consumable_changed (enemies : Array[Health])
signal consuming_enemy

var _motion := Vector2.ZERO
var _last_motion := Vector2.RIGHT
var _last_aim := Vector2.ZERO

# STOMACH
@export_group("STOMACH")
@export var durability_acid_rate := 0.25
var stomach : Array[WeaponBase] = [null, null]
signal stomach_updated(curWeapon : WeaponBase, stomach : Array[WeaponBase])

func _enter_tree():
	GameManager.Player = self
	# Should hit enemy (6) and damageables (2)
	# And not hit player (5) and nexus (7)
	damage_matrix = [
		[6 , true],
		[2 , true],
		[5 , false],
		[7 , false],
	]

func _ready():
	stomach_updated.emit(currentWeapon, stomach)

func _physics_process(delta: float) -> void:
	if mainActionInput.is_pressed :
		if currentWeapon == null :
			# Use goop instead
			goop.attack(self)
		else :
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
	
	if _is_consuming :
		return _last_aim
	
	# TODO: Make it use input instead of just mouse
	_last_aim = get_global_mouse_position()
	return _last_aim

func on_weapon_pick(newWeapon : WeaponBase):
	# Check if has already in hand
	# Can't be the same weapon because we might just want to update col matrix
	if newWeapon != currentWeapon and currentWeapon != null:
		# If so, it should go to an empty slot in the inventory
		for slot in stomach.size():
			var slotWeapon = stomach[slot]
			if slotWeapon == null or not is_instance_valid(slotWeapon):
				print("[STOMACH] Free slot on pickup ", slot)
				stomach[slot] = newWeapon
				TinyUtils.set_active(newWeapon, false)
				stomach_updated.emit(currentWeapon, stomach)
				return
		
		# If no empty slot, drop it
		print("[STOMACH] No empty slot, dropping back")
		newWeapon.Drop(self, global_position, global_rotation)
		return
	
	# Empty handed, go as usual
	super.on_weapon_pick(newWeapon)
	stomach_updated.emit(newWeapon, stomach)

func can_pickup_weapon(possibleWeapon : WeaponBase) -> bool:
	if possibleWeapon.unitOwner != null:
		return false # No need to check anything else if already has an owner
	
	# Check if has any free slot
	for slot in stomach.size():
		var weapon = stomach[slot]
		if weapon == null or not is_instance_valid(weapon):
			return true
	
	return super.can_pickup_weapon(possibleWeapon)

# SIGNALS
func _on_drop_action_on_input_press():
	TryDropAction()
	stomach_updated.emit(currentWeapon, stomach)

func _on_health_hit(attacker, health : Health):
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
	dash.emit()
	await get_tree().create_tween().tween_property(
		bodyNode, "scale", ogScale, _current_impulse_duration).finished
	_is_dashing = false
	await get_tree().create_timer(_dashCooldown).timeout
	_can_dash = true


func _on_consume_action_on_input_press():
	if _possible_enemies_consumable.is_empty() or _is_checking_consume:
		return
	
	_is_checking_consume = true
	
	# Then check if they can be consumed
	for index in range(_possible_enemies_consumable.size() - 1, -1, -1):
		var enemy = _possible_enemies_consumable[index]
		if not is_valid_enemy_to_consume(enemy) :
			# Just ignore, it'll be removed after an enemy is killed
			continue
		
		if not can_consume(enemy) :
			continue
		
		if not TinyMath.is_in_range(global_position, enemy.global_position, _consume_area) :
			continue
		
		# This enemy will be consumed
		_last_aim = global_position - enemy.global_position
		enemy.ApplyDamage(null, enemy.curHealth)
		GameManager.add_score(_consume_recover) # extra score for consume
		goop.add(_consume_recover)
		canMove = false
		_is_consuming = true
		consuming_enemy.emit()
		var ogScale = bodyNode.scale
		bodyNode.scale = Vector2(_dash_stretch, ogScale.y * 2)
		var consumeTween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		consumeTween.tween_property(self, "global_position", enemy.global_position, 0.15)
		consumeTween.tween_property(bodyNode, "scale", ogScale, 0.15)
		await consumeTween.finished
		canMove = true
		# Don't break, lets make a option of consuming everyone in range
	print("Finished consuming")
	_is_consuming = false
	_is_checking_consume = false

func can_consume(unit : Health) -> bool :
	var percentage = unit.curHealth / unit.maxHealth
	print("Check consume: " , percentage)
	# Check threhsold, but ignore already dead enemies
	var below_threshold = percentage > 0 and percentage <= _consume_threshold
	
	var possible_enemies_changed = false
	
	if below_threshold and not _possible_enemies_consumable.has(unit):
		print("Adding enemy to possible consume")
		_possible_enemies_consumable.append(unit)
		possible_enemies_changed = true
	
	# Clean invalid enemies
	for e in range(_possible_enemies_consumable.size() - 1, -1, -1):
		var enemy = _possible_enemies_consumable[e]
		if not is_valid_enemy_to_consume(enemy):
			_possible_enemies_consumable.remove_at(e)
			possible_enemies_changed = true
	
	enemies_consumable_changed.emit(_possible_enemies_consumable)
	
	return below_threshold

func is_valid_enemy_to_consume(enemy) -> bool :
	if enemy == null or not is_instance_valid(enemy) :
		return false

	if enemy.is_queued_for_deletion() :
		return false
	
	if enemy is Health :
		var enemy_health : Health = enemy
		if enemy_health.curHealth <= 0 :
			return false # Already dead, can't consume
		
		var parentEnemy = enemy_health.parent # Parent is tagged for deletion before children
		if parentEnemy == null or not is_instance_valid(parentEnemy) :
			return false
		
		if parentEnemy.is_queued_for_deletion() :
			return false
	
	return true

func _on_change_e_on_input_press():
	# Change current to first weapon
	var slotWeapon = stomach[0]
	if slotWeapon == null or not is_instance_valid(slotWeapon):
		return # No weapon to change
	TinyUtils.set_active(currentWeapon, false)
	TinyUtils.set_active(slotWeapon, true)
	stomach[0] = currentWeapon
	currentWeapon = slotWeapon
	on_weapon_pick(currentWeapon)
	stomach_updated.emit(currentWeapon, stomach)

func _on_change_q_on_input_press():
	# Change current to second weapon
	var slotWeapon = stomach[1]
	if slotWeapon == null or not is_instance_valid(slotWeapon):
		return # No weapon to change
	TinyUtils.set_active(currentWeapon, false)
	TinyUtils.set_active(slotWeapon, true)
	stomach[1] = currentWeapon
	currentWeapon = slotWeapon
	on_weapon_pick(currentWeapon)
	stomach_updated.emit(currentWeapon, stomach)

func _on_acid_timeout():
	if currentWeapon != null and is_instance_valid(currentWeapon):
		# On next tick, destroy if below
		if currentWeapon.durability <= 0:
			currentWeapon.queue_free()
			currentWeapon = null
		else : 
			currentWeapon.durability -= durability_acid_rate # Normal rate when held
	
	for slot in stomach.size():
		var weapon = stomach[slot]
		if weapon != null and is_instance_valid(weapon):
			# On next tick, decrease if below
			if weapon.durability <= 0:
				weapon.queue_free()
				stomach[slot] = null
			else :
				weapon.durability -= durability_acid_rate * 0.5 # Slower when in stomach
	
	stomach_updated.emit(currentWeapon, stomach) # Update UI
