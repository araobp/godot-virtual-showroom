extends Node3D

@export var gemini_api_key = ""

var gemini
var SYSTEM_INSTRUCTION = "You are an AI robot with Generative AI."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gemini = load("res://SceneControl/gemini.gd").new(
			$HTTPRequest,
			self,
			null,
			SYSTEM_INSTRUCTION
		)

	$Control/Input.insert_text_at_caret("You: ")
	$Control/Input.grab_focus()


var processing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")

	"""
	elif Input.is_key_pressed(KEY_P):
		start_animation({"action": "point"})

	elif Input.is_key_pressed(KEY_D):
		start_animation({"action": "dance"})

	elif Input.is_key_pressed(KEY_J):
		start_animation({"action": "jump"})
		
	elif Input.is_key_pressed(KEY_S):
		start_animation({"action": "stop"})
	"""
	
	if !processing and Input.is_key_pressed(KEY_ENTER) and $Control/Input.text != "":
		processing = true
		var text = $Control/Input.text
		var response_text = await gemini.chat(
			text,
			function_declarations,
			)
		$Control/Input.insert_text_at_caret("Gemini: " + response_text + "\nYou: ", -1)
		$Control/Input.scroll_vertical = 10000
		processing = false


func start_animation(arg):
	var robot = $SubViewportContainer/SubViewport/Robot
	match arg["action"]:
		"point": robot.point()
		"dance": robot.dance()
		"jump": robot.jump()
		"stop": robot.stop()
		
const function_declarations = [
	start_animation_description,
]
		
const start_animation_description = {
	"name": "start_animation",
	"description": """
	A function to make the AI robot start one of the following actions:
		- "point": the AI robot points forward with its right arm.
		- "dance": the AI robot dances.
		- "jump": the AI robot jumps.
		- "stop": the AI robot stops the other action and becomes idle.		
	""",
	"parameters": {
		"type": "object",
		"properties": {
			"action": {
				"type": "string",
				"enum": ["point", "dance", "jump", "stop"],
				"description": "A list of actions of the AI robot:
				- point: the AI robot points forward with its right arm.
				- dance: the AI robot dances.
				- jump: the AI robot jumps.
				- stop: the AI robot stops the other action and becomes idle."
			},
		},
		"required": ["action"],
	}
}
