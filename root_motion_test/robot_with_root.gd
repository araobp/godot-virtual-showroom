extends Node3D

var state_machine

@export var ROTATION_Y_SPEED = 1
var rot_y_accumlator = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine = $AnimationTree["parameters/playback"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# print($AnimationTree.get_root_motion_position())
	var pos = $AnimationTree.get_root_motion_position()
	$Armature.global_position += pos.rotated(Vector3.UP, rot_y_accumlator)
	
	if Input.is_key_pressed(KEY_UP):
		state_machine.travel("Walk")
	elif Input.is_key_pressed(KEY_DOWN):
		state_machine.travel("Idle")
	elif Input.is_key_pressed(KEY_RIGHT):
		var rot_y = -ROTATION_Y_SPEED * delta
		rot_y_accumlator += rot_y
		$Armature.rotate_y(rot_y)
	elif Input.is_key_pressed(KEY_LEFT):
		var rot_y = ROTATION_Y_SPEED * delta
		rot_y_accumlator += rot_y
		$Armature.rotate_y(rot_y)
		
