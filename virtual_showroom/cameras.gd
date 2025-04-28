extends Node3D

var cameras

var idx = 0
var N

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cameras = get_children()
	N = len(cameras)
	cameras[0].make_current()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_right_arrow_camera_button_down() -> void:
	if idx < N - 1:
		idx += 1
	cameras[idx].make_current()


func _on_texture_button_left_arrow_camera_button_down() -> void:
	if idx > 0:
		idx -= 1
	cameras[idx].make_current()
