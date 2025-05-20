extends Node

# Gemini API Key
var GEMINI_API_KEY_FILE_PATH = "res://gemini_api_key_env.txt"
var GEMINI_API_KEY = ""

var SYSTEM_INSTRUCTION

var HTTP_REQUEST
var CALLABLE_INSTANCE

# Get an environment variable in the file
func _get_environment_variable(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	content = content.strip_edges()
	return content

func _init(http_request, callable_instance, gemini_api_key=null, system_instruction="") -> void:

	HTTP_REQUEST = http_request
	CALLABLE_INSTANCE = callable_instance
	
	if gemini_api_key == null:
		GEMINI_API_KEY = _get_environment_variable(GEMINI_API_KEY_FILE_PATH)
	else:
		GEMINI_API_KEY =gemini_api_key
		
	SYSTEM_INSTRUCTION = system_instruction
	


func chat(query, function_declarations=null):
	
	const headers = [
		"Content-Type: application/json",
		"Accept-Encoding: identity"
	]
	
	var payload = {
		"system_instruction": {
			"parts": [
				{
					"text": SYSTEM_INSTRUCTION
				}
			]
		},
		"contents": [
			{
				"role": "user",
				"parts": [
					{
						"text": query
					}
				]
			}
		]
	}
	
	if function_declarations:
		payload["tools"] = [
			{
				"functionDeclarations": function_declarations
			}
		]
		
	print(payload)
		
	var err = HTTP_REQUEST.request(
		"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + GEMINI_API_KEY,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)
	
	if err != OK:
		return

	var res = await HTTP_REQUEST.request_completed

	var body = res[3]
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	
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
			var callable = Callable(CALLABLE_INSTANCE, func_name)
			callable.call(args)
		
		if "finishReason" in candidate and candidate["finishReason"] == "STOP":
			print("STOP")
	
	return response_text
	
	
	{ "system_instruction": {
		"parts": [
			{ "text": "You are an AI assistant good at controlling an AI robot remotely." }
		]
	}, 
	"contents": [
		{ "role": "user", "parts":
			[
				{ "text": "You: Dance\n" }
			]
		}
	],
	"tools": [
		{ "functionDeclarations":
			{ "name": "start_animation",
			"description": "The AI robot makes an action.",
			"parameters": { "type": "object", "properties": { "action": { "type": "string", "enum": ["point", "dance", "jump", "idle"], "description": "A list of actions of the AI robot:\n\t\t\t\t- point: the AI robot points forward with its right arm.\n\t\t\t\t- dance: the AI robot dances.\n\t\t\t\t- jump: the AI robot jumps.\n\t\t\t\t- idle: the AI robot becomes idle." } }, "required": ["brightness", "color_temp"] } } }] }
