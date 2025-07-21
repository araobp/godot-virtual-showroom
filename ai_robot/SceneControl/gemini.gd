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
	

var history = []
var session_id = 0
var req_num
const N = 10
const FINISHED = "---FINISHED---"

func chat(query, function_declarations=null, enable_history=false, _first_in_session=true):
	var query_original = query
	if _first_in_session:
		req_num = 0
		session_id += 1
	
	if enable_history:
		query = """Determine the next action by referring to response_from_gemini in the history of this chat session with session_id {session_id}.

The history of this chat session is comprised of entries where the session_id is {session_id}.
If you do not see the session_id {session_id} in the history, this request is the first one in the chat session.

If there's nothing else to do after this, say somthing and add this text after that without any extra characters: "{finished}"

# query

{query}

# history

{history}

""".format({"session_id": session_id, "finished": FINISHED, "query": query, "history": history})
	
	# print(query)
	
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
		
	# print(payload)
		
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

	# print(json)

	var response_text = null
	var function_call = null
		
	for part in parts:
		if "text" in part:
			response_text = part["text"]
			print(response_text)

		elif "functionCall" in part:
			function_call = part["functionCall"]
			var func_name = function_call["name"]
			var args = function_call["args"]
			print(func_name, args)	
			var callable = Callable(CALLABLE_INSTANCE, func_name)
			callable.call(args)
		
		if enable_history:
			if _first_in_session:
				_first_in_session = false
							
			req_num += 1
			var h = {
				"session_id": session_id,
				"request_number_in_session": req_num,
				"query_to_gemini": query_original,
				"response_from_gemini": {
					"text_from_gemini": null,
					"function_call_from_gemini": function_call
				}
			}
			history.append(h)
			print(h)
		
	
	if function_declarations and enable_history:
		if function_call or response_text and FINISHED not in response_text:
			chat(query_original, function_declarations, true, _first_in_session)
	
	if response_text == null or response_text == "":
		response_text = "OK"
	elif FINISHED in response_text:
		response_text = response_text.replace(FINISHED, "")
		
	return response_text
