extends Camera3D

var original_position
var original_rotation

var DELTA_POS = 0.02
var delta_pos = Vector3(0, 0, 0)

var DELTA_Z_ROTATION = PI/300
var delta_z_rotation = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = position
	original_rotation = rotation
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += delta_pos
	rotate(Vector3.UP, delta_z_rotation);


func _on_button_forward_button_down() -> void:
	delta_pos = transform.basis.z * -DELTA_POS


func _on_button_forward_button_up() -> void:
	delta_pos = Vector3(0, 0, 0)


func _on_button_backward_button_down() -> void:
	delta_pos = transform.basis.z * DELTA_POS


func _on_button_backward_button_up() -> void:
	delta_pos = Vector3(0, 0, 0)


func _on_button_left_button_down() -> void:
	delta_z_rotation = DELTA_Z_ROTATION


func _on_button_left_button_up() -> void:
	delta_z_rotation = 0


func _on_button_right_button_down() -> void:
	delta_z_rotation = -DELTA_Z_ROTATION


func _on_button_right_button_up() -> void:
	delta_z_rotation = 0
	

func _on_button_reset_position_button_down() -> void:
	position = original_position
	rotation = original_rotation
