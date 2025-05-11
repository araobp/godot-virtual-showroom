extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")

	elif Input.is_key_pressed(KEY_P):
		var state_machine = $SubViewportContainer/SubViewport/Robot/AnimationTree["parameters/playback"]
		state_machine.travel("Point")
