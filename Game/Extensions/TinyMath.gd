class_name TinyMath

static func is_even(x) -> bool:
	if typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT:
		return int(x) % 2 == 0
	else:
		print("Error: Argument is not an integer or a float.")
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
