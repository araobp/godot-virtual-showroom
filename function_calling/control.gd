extends Control

# Gemini API Key
var GEMINI_API_KEY_FILE_PATH = "res://gemini_api_key_env.txt"
@export var GEMINI_API_KEY = ""

# Get an environment variable in the file
func _get_environment_variable(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	content = content.strip_edges()
	return content
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GEMINI_API_KEY == "":
		GEMINI_API_KEY = _get_environment_variable(GEMINI_API_KEY_FILE_PATH)	
	
	$TextInput.insert_text_at_caret("You: ")
	$TextInput.grab_focus()

var processing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !processing and Input.is_key_pressed(KEY_ENTER) and $TextInput.text != "":
		processing = true
		var text = $TextInput.text
		var response_text = await _chat(text)
		$TextInput.insert_text_at_caret("Gemini: " + response_text + "\nYou: ", -1)
		$TextInput.scroll_vertical = 10000
		processing = false

const _set_light_values = {
	"name": "set_light_values",
	"description": "Sets the brightness and color of a light.",
	"parameters": {
		"type": "object",
		"properties": {
			"brightness": {
				"type": "number",
				"description": "Light level from 0.0 to 10.0. Zero is off and 10 is full brightness",
			},
			"color_temp": {
				"type": "string",
				"enum": ["daylight", "cool", "warm"],
				"description": "Color temperature of the light fixture, which can be `daylight`, `cool` or `warm`."
			},
		},
		"required": ["brightness", "color_temp"],
	}
}

const _open_door = {
	"name": "open_door",
	"description": "Opens or closes the door. The door is connected to the building by hinges.",
	"parameters": {
		"type": "object",
		"properties": {
			"rotation": {
				"type": "number",
				"description": "The door's hinge rotation in degrees from 0 to 120. When asked to close the door, the value is zero. And when asked to open the door, the value is 90.",
			},
		},
		"required": ["rotation"],
	}
}



func _chat(text):
	
	const headers = [
		"Content-Type: application/json",
	]
	
	var payload = {
		"system_instruction": {
			"parts": [
				{
					"text": "You are an AI assistant skilled at controlling the light and opening/closing the door"
				}
			]
		},
		"contents": [
			{
				"role": "user",
				"parts": [
					{
						"text": text
					}
				]
			}
		],
		"tools": [
			{
				"functionDeclarations": [
					_set_light_values,
					_open_door
				]
			}
		]
	}
		
	var req = HTTPRequest.new()
	self.add_child(req)
	
	var err = req.request(
		"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + GEMINI_API_KEY,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)
	
	if err != OK:
		return

	var res = await req.request_completed

	var body = res[3]
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print(json)

	var candidate = json["candidates"][0]
	var parts = candidate["content"]["parts"]

	var response_text = "OK\n"	
	
	for part in parts:
		if "text" in part:
			response_text = part["text"]
			print(response_text)
		elif "functionCall" in part:
			var function_call = part["functionCall"]
			var func_name = function_call["name"]
			var args = function_call["args"]
			print(func_name, args)	
			var callable = Callable(get_parent(), func_name)
			callable.call(args)
		
		if "finishReason" in candidate and candidate["finishReason"] == "STOP":
			print("STOP")

	self.remove_child(req)
	
	return response_text
