extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func to_recognition_scene() -> void:
	get_tree().change_scene_to_file("res://SceneRecognition/recognition.tscn")

func to_control_scene() -> void:
	get_tree().change_scene_to_file("res://SceneControl/control.tscn")
