class_name TinyMath

static func is_even(x) -> bool:
	if typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT:
		return int(x) % 2 == 0
	else:
		print("[TINY MATH]: Error! Argument is not an integer or a float.")
		return false

static func to_float(condition : bool) -> int:
	if condition :
		return 1
	else :
		return 0

static func pick(condition : bool, trueReturn, falseReturn):
	if condition :
		return trueReturn
	else :
		return falseReturn

static func rotation_to_direction(rotation):
	return Vector2(cos(rotation), sin(rotation))

static func is_in_range(source: Vector2, target: Vector2, range: float) -> bool:
	var distance = source.distance_to(target)
	return distance <= range
