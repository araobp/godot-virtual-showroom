extends Node

# Gemini API Key
var GEMINI_API_KEY_FILE_PATH = "res://gemini_api_key_env.txt"
var GEMINI_API_KEY = ""

var SYSTEM_INSTRUCTION

var CALLABLE_INSTANCE

# Get an environment variable in the file
func _get_environment_variable(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	content = content.strip_edges()
	return content

func _init(gemini_api_key=null, system_instruction="", callable_instance=null) -> void:
	
	if gemini_api_key == null:
		GEMINI_API_KEY = _get_environment_variable(GEMINI_API_KEY_FILE_PATH)
	else:
		GEMINI_API_KEY =gemini_api_key
		
	SYSTEM_INSTRUCTION = system_instruction
	
	if callable_instance:
		CALLABLE_INSTANCE = self
	else:
		CALLABLE_INSTANCE = callable_instance


func chat(query, function_declarations=null):
	
	const headers = [
		"Content-Type: application/json",
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
			var callable = Callable(CALLABLE_INSTANCE, func_name)
			callable.call(args)
		
		if "finishReason" in candidate and candidate["finishReason"] == "STOP":
			print("STOP")

	self.remove_child(req)
	
	return response_text
	
