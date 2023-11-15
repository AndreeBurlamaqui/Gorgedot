extends ProjectileController

var wave_time = 0
var amplitude = 100


func _physics_process(delta):
	if !canMove:
		return
	
	wave_time += delta
	var direction = GetDirection()
	var wave_magnitude = sin(wave_time * -2 * PI) * amplitude
	var wave_direction = Vector2(direction.y, direction.x)
	var velocity = direction * speed * wave_direction * wave_magnitude
	position += velocity * delta
