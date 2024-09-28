class_name Camera extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	CameraManager.SetMainCamera(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
