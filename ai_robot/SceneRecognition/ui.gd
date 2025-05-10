extends CanvasLayer

# Gemini API Key
var GEMINI_API_KEY_FILE_PATH = "res://gemini_api_key_env.txt"
@export var GEMINI_API_KEY = ""

# Chat query
var query = ""

# TTS
var voices

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
	$ChatWindow.visible = false
	
	voices = DisplayServer.tts_get_voices_for_language("en")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ENTER) and $ChatWindow/TextInput.text != "":
		query = $ChatWindow/TextInput.text
		$ChatWindow/TextInput.text = ""
		$ChatWindow/TextOutput.text = "Q: {0}".format([query])
	
		chat()


func chat():
	var b64image = get_parent().capture_image_from_robot_camera()
	
	const headers = [
		"Content-Type: application/json",
	]
	
	var payload = {
		"system_instruction": {
			"parts": [
				{
					"text": "You are an AI assistant skilled at describing photos."
				}
			]
		},
		"contents": [
			{
				"parts":[
					{
						"inline_data": {
							"mime_type":"image/jpeg",
							"data": b64image
						}
					},
					{
						"text": query
					},
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

	var res = await req.request_completed # request_completed シグナルを待つ

	var body = res[3]
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	# print(json)
	var answer = json["candidates"][0]["content"]["parts"][0]["text"]

	get_parent().start_point_animation()
	_output_text(answer)
	DisplayServer.tts_speak(answer, voices[0])

	self.remove_child(req)


func _on_chat_toggle_button_button_down() -> void:
	if $ChatWindow.visible:
		$ChatWindow.visible = false
	else:
		$ChatWindow.visible = true
		$ChatWindow/TextInput.grab_focus()


func _output_text(answer):
	$ChatWindow/TextOutput.text += "A: {0}\n\n".format([answer])

	$ChatWindow/TextInput.grab_focus()
