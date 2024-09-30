extends Node

var mainCamera : Camera
var shakeTween : Tween

func SetMainCamera(newCam : Camera):
	mainCamera = newCam

func Shake(intensity : float, duration : float):
	if shakeTween and shakeTween.is_valid(): # Cancel any ongoing shake
		shakeTween.kill()
	
	var oldPos = mainCamera.global_position
	shakeTween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	shakeTween.tween_method(_shake_progress.bind(intensity), 0.0, 1.0, duration)
	shakeTween.play()
	await shakeTween.finished
	mainCamera.global_position = oldPos

func _shake_progress(progress : float, intensity : float):
	var decreaser = 1.0 - progress
	var randX = randf_range(-1, 1) * intensity * decreaser
	var randY = randf_range(-1, 1) * intensity * decreaser
	mainCamera.global_position = Vector2(randX, randY)
	# print("Shaking camera by ", mainCamera.global_position, "[%.2f/1]" %decreaser)
