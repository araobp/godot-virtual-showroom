extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print($AnimationTree.get_root_motion_position())
	var pos = $AnimationTree.get_root_motion_position()
	$Armature.global_position += pos
	
