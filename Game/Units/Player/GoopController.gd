class_name GoopController extends Node2D

@export var health : Health
@export var goop_weapon : WeaponRanged
@export var goop_weapon_cost := 5
var _max_goop := 200
var cur_goop := 0

signal on_update(max : float, current : float)

func _ready():
	health.on_hit.connect(_on_health_hit)
	reset(health.maxHealth)
	goop_weapon.unitOwner = GameManager.Player

func free():
	health.on_hit.disconnect(_on_health_hit)

func reset(initialValue : float):
	_max_goop = initialValue
	_update(_max_goop)

func _update(newValue : float):
	cur_goop = min(newValue, _max_goop)
	health.curHealth = cur_goop
	health.CheckDeath()
	on_update.emit(_max_goop, cur_goop)

func _on_health_hit(attacker : Hitbox, healthComponent : Health):
	_update(health.curHealth)

func reduce(value : float):
	_update(cur_goop - value)

func add(value : float):
	_update(cur_goop + value)

func attack(player : UnitController):
	goop_weapon.TryUse(player)
	reduce(goop_weapon_cost)
