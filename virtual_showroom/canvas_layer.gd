extends CanvasLayer

# Gemini API Key
var GEMINI_API_KEY_FILE_PATH = "res://gemini_api_key_env.txt"
@export var GEMINI_API_KEY : String = ""

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
		$ChatWindow/TextOutput.text += "Q: {0}".format([query])
		$ChatWindow/TextOutput.scroll_vertical = 10000
		
		chat()
		
	if not DisplayServer.tts_is_speaking():
		get_parent().get_node("Models").speak(false)			


# Capture image from Camera3D attached to the sub viewport
func _capture(resize_width=null):

	# Get the image data	 from sub viewport
	var viewport = get_parent().get_node("SubViewportContainer/SubViewport").get_viewport()
	var image = viewport.get_texture().get_image()

	if resize_width:
		var viewport_size = viewport.size
		var img_width = resize_width
		var img_height = int(img_width * viewport_size[1]/viewport_size[0])
		image.resize(img_width, img_height)

	# Encode the image to Base64
	var b64image = Marshalls.raw_to_base64(image.save_jpg_to_buffer())

	return b64image
	

func chat():
	var place = get_parent().image_place()
	
	var b64image = _capture(800)
	
	const headers = [
		"Content-Type: application/json",
	]
	
	var payload = {
		"system_instruction": {
			"parts": [
				{
					"text": "The scene on the screen is a picture taken in {0}.".format([place])
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

	print(json)
	var answer = json["candidates"][0]["content"]["parts"][0]["text"]
	_output_text(answer)
	
	var model_idx = get_parent().get_node("Models").model_idx()
	DisplayServer.tts_speak(answer, voices[model_idx])

	get_parent().get_node("Models").speak(true)

	self.remove_child(req)

func _on_chat_toggle_button_button_down() -> void:
	if $ChatWindow.visible:
		$ChatWindow.visible = false
	else:
		$ChatWindow.visible = true
		$ChatWindow/TextInput.grab_focus()


func _output_text(answer):
	$ChatWindow/TextOutput.text += "A: {0}\n\n".format([answer])
	$ChatWindow/TextOutput.scroll_vertical = 10000

	$ChatWindow/TextInput.grab_focus()
