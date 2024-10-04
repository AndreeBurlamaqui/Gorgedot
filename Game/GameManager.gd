extends Node

var Player : PlayerController
var Family : Nexus
var current_score := 0
enum GameState { PLAYING, FAMILY_DEAD, PLAYER_DEAD, BOSS_KILLED }
var state := GameState.PLAYING

signal score_changed (newScore : int)
signal game_ended (state : GameState)

func _ready():
	state = GameState.PLAYING
	process_mode = Node.PROCESS_MODE_ALWAYS

func add_score(value : int) :
	current_score += value
	score_changed.emit(current_score)

func end_game(newState : GameState) :
	state = newState
	game_ended.emit(state)
	# Stop the game
	get_tree().paused = true
	Engine.time_scale = 0

func restart_game() :
	get_tree().paused = false
	Engine.time_scale = 1
	state = GameState.PLAYING
	get_tree().reload_current_scene()
