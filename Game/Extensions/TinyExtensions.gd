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
	
