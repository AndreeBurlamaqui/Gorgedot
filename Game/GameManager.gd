extends Node

var Player : PlayerController
var Family : Nexus
var current_score := 0
enum EndState { FAMILY_DEAD, PLAYER_DEAD, BOSS_KILLED }

signal score_changed (newScore : int)
signal game_ended (state : EndState)

func add_score(value : int) :
	current_score += value
	score_changed.emit(current_score)

func end_game(state : EndState) :
	Engine.time_scale = 0 # Stop the game
	game_ended.emit(state)

func restart_game() :
	get_tree().reload_current_scene()
