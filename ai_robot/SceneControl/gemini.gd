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

	var contents = [
  		{
			"role": "user",
			"parts": [
	  			{
					"text": query,
	  			},
			],
  		}
	]

	var payload = {
		"contents": contents
	}
	
	if function_declarations:
		payload["tools"] = [
			{
				"functionDeclarations": function_declarations
			}
		]
	
	var response_text = null

	while true:
		
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

		var functionCalled = false
				
		for part in parts:
			if "text" in part:
				response_text = part["text"]
				print(response_text)
				
			if "functionCall" in part:
				var functionCall = part["functionCall"]
				var func_name = functionCall["name"]
				var args = functionCall["args"]
				print(func_name, args)	
				
				var callable = Callable(CALLABLE_INSTANCE, func_name)
				var result = await callable.call(args)
				
				var functionResponsePart = {
					"name": func_name,
					"response": {
						"result": result
					}
				}
				
				contents.append(
					{
						"role": "model",
						"parts": [
							{
								"functionCall": functionCall
							}
						]
					}
				)
				
				contents.append(
					{
						"role": "user",
						"parts": [
							{
								"functionResponse": functionResponsePart,
							}
						]
					}
				)
				
				functionCalled = true
					
		if not functionCalled:
			break
			
	return response_text
