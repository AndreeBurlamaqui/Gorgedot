extends Node

var mainCamera : Camera
var noise : FastNoiseLite
var shakeTween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	noise = FastNoiseLite.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func SetMainCamera(newCam : Camera):
	mainCamera = newCam

func Shake(intensity : float, duration : float):
	if shakeTween != null:
		shakeTween.kill()
	shakeTween = create_tween()
	var force = noise.get_noise_1d(Time.get_ticks_msec() * intensity)
	var randomX = randf_range(-intensity, intensity)
	var randomY = randf_range(-intensity, intensity)
	var offset = Vector2(force * randomX, force * randomY)
	var oldPos = mainCamera.global_position
	shakeTween.tween_property(mainCamera, "global_position", offset, duration)
	shakeTween.tween_property(mainCamera, "global_position", oldPos, duration * 0.15)
	shakeTween.play()
	await shakeTween.finished
	mainCamera.global_position = oldPos
