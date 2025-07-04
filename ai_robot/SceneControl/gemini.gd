extends Node

var GEMINI_API = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

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
		GEMINI_API + "?key=" + GEMINI_API_KEY,
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

	print(json)

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
