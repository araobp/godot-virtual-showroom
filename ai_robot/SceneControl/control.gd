extends Node3D

@export var gemini_api_key = ""

var gemini
var SYSTEM_INSTRUCTION = "You are an AI assistant good at controlling a robot remotely."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gemini = load("res://SceneControl/gemini.gd").new(gemini_api_key, SYSTEM_INSTRUCTION)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")

	elif Input.is_key_pressed(KEY_P):
		$SubViewportContainer/SubViewport/Robot.point()

	elif Input.is_key_pressed(KEY_D):
		$SubViewportContainer/SubViewport/Robot.dance()

	elif Input.is_key_pressed(KEY_J):
		$SubViewportContainer/SubViewport/Robot.jump()
		
	elif Input.is_key_pressed(KEY_I):
		$SubViewportContainer/SubViewport/Robot.idle()
	
