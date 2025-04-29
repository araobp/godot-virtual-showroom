extends Node3D

var cameras

var idx = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cameras = get_children()
	cameras[0].current = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func next_camera():
	if idx < len(cameras) - 1:
		idx += 1
		cameras[idx].current = true

func prev_camera():
	if idx > 0:
		idx -= 1
		cameras[idx].current = true
		
