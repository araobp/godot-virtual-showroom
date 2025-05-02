extends Node3D

const speed = 2
const angular_speed = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_key_pressed(KEY_W):
		position -= transform.basis.z * speed * delta;
	elif Input.is_key_pressed(KEY_S):
		position += transform.basis.z * speed * delta;

	if Input.is_key_pressed(KEY_L):
		position += transform.basis.x * speed * delta * 0.5;
	elif Input.is_key_pressed(KEY_J):
		position -= transform.basis.x * speed * delta * 0.5;
	
	if Input.is_key_pressed(KEY_D):
		rotate(Vector3.UP, -delta * angular_speed)
	elif Input.is_key_pressed(KEY_A):
		rotate(Vector3.UP, delta * angular_speed)

	if Input.is_key_pressed(KEY_I):
		position += transform.basis.y * speed * delta * 0.5
	elif Input.is_key_pressed(KEY_K):
		position -= transform.basis.y * speed * delta * 0.5
