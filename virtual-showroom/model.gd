extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var speak = $AnimationTree.get_animation("Speak")
	speak.loop_mode = false
	var playback = $AnimationTree.get("parameters/playback")
	playback.travel("SitDown");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func stand_up():
	var playback = $AnimationTree.get("parameters/playback")
	playback.travel("StandUp");

func sit_down():
	var playback = $AnimationTree.get("parameters/playback")
	playback.travel("RestPose")


func start_speaking():
	var speak = $AnimationTree.get_animation("Speak")
	speak.loop_mode = true

func stop_speaking():
	var speak = $AnimationTree.get_animation("Speak")
	speak.loop_mode = false
	
	
