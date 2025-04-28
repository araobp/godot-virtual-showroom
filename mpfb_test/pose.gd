extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var speak = $AnimationTree.get_animation("Speak")
	speak.loop_mode = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_stand_up_button_down() -> void:
	var playback = $AnimationTree.get("parameters/playback")
	playback.travel("StandUp");



func _on_button_sit_down_button_down() -> void:
	var speak = $AnimationTree.get_animation("Speak")
	speak.loop_mode = false
	var playback = $AnimationTree.get("parameters/playback")
	playback.travel("SitDown");
	
	


func _on_button_speak_button_down() -> void:
	var speak = $AnimationTree.get_animation("Speak")
	if speak.loop_mode == 1:
		speak.loop_mode = false
	else:
		speak.loop_mode = true
