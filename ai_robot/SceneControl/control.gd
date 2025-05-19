extends Node3D

@export var gemini_api_key = ""

var gemini
var SYSTEM_INSTRUCTION = "You are an AI assistant good at controlling a robot remotely."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gemini = load("res://SceneControl/gemini.gd").new($HTTPRequest, self, null, SYSTEM_INSTRUCTION)

	$Control/Input.insert_text_at_caret("You: ")
	$Control/Input.grab_focus()


var processing = false

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
	
	
	if !processing and Input.is_key_pressed(KEY_ENTER) and $Control/Input.text != "":
		processing = true
		var text = $Control/Input.text
		var response_text = await gemini.chat(text)
		$Control/Input.insert_text_at_caret("Gemini: " + response_text + "\nYou: ", -1)
		$Control/Input.scroll_vertical = 10000
		processing = false
