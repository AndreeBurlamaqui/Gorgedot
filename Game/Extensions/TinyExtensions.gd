class_name TinyUtils

static func get_end_point(raycast: RayCast2D) -> Vector2:
	var rotated_target_position = raycast.target_position.rotated(raycast.global_rotation)
	if raycast.is_colliding():
		# If the raycast is colliding with something, return the collision point
		return raycast.get_collision_point()
	else:
		# If the raycast is not colliding with anything, return the end point
		return raycast.global_position + rotated_target_position

static func visualize_raycast(raycast: RayCast2D, duration: float, lineColor : Color) :
	var line = Line2D.new()
	line.default_color = lineColor
	line.width = 5
	
	line.add_point(raycast.global_position)
	line.add_point(get_end_point(raycast))
	raycast.get_tree().root.add_child(line)
	
	# Create a timer to remove the line after the duration
	var timer = Timer.new()
	raycast.get_tree().root.add_child(timer)
	timer.wait_time = duration
	timer.one_shot = true
	timer.start()
	# Start the timer and add it to the current scene
	await timer.timeout
	line.queue_free()
	timer.queue_free()

static func visualize_angle(origin : Node2D, angle : Vector2, duration : float, lineColor : Color):
	var min_angle = deg_to_rad(angle.x) + origin.global_rotation - PI/2
	var max_angle = deg_to_rad(angle.y) + origin.global_rotation - PI/2
	
	var line = Line2D.new()
	line.default_color = lineColor
	line.width = 5
	
	var minDir = Vector2(cos(min_angle), sin(min_angle))
	line.add_point(origin.global_position + minDir * 100)
	line.add_point(origin.global_position)
	var maxDir = Vector2(cos(max_angle), sin(max_angle))
	line.add_point(origin.global_position + maxDir * 100)
	
	origin.get_tree().root.add_child(line)
	
	# Create a timer to remove the line after the duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	# Start the timer and add it to the current scene
	line.get_tree().root.add_child(timer)
	timer.start()
	await timer.timeout
	line.queue_free()
	timer.queue_free()

static func set_time_scale(newScale : float, duration : float):
	Engine.time_scale = newScale
	await Engine.get_main_loop().create_timer(duration * newScale, true, false, true).timeout
	Engine.time_scale = 1
