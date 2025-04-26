extends CanvasLayer

# Gemini API Key
var GEMINI_API_KEY_FILE_PATH = "res://gemini_api_key_env.txt"
var GEMINI_API_KEY = ""

# Chat query
var query = ""

func get_environment_variable_from_file(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	content = content.strip_edges()
	return content


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ChatWindow.visible = false
	
	$HTTPRequest.request_completed.connect(_on_request_completed)
	GEMINI_API_KEY = get_environment_variable_from_file(GEMINI_API_KEY_FILE_PATH)	
	# print("Gemini API Key: " + GEMINI_API_KEY)


func _capture_viewport(resize_width=null):

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
	var b64image = _capture_viewport(640)
	
	const headers = [
		"Content-Type: application/json",
	]
	
	var payload = {
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
		
	$HTTPRequest.request(
		"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + GEMINI_API_KEY,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	var answer = json["candidates"][0]["content"]["parts"][0]["text"]
	output_text(answer)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ENTER) and $ChatWindow/TextInput.text != "":
		query = $ChatWindow/TextInput.text
		$ChatWindow/TextInput.text = ""
		$ChatWindow/TextOutput.text += "Q: {0}".format([query])
		$ChatWindow/TextOutput.scroll_vertical = 10000
		

		chat()



func _on_chat_toggle_button_button_down() -> void:
	if $ChatWindow.visible:
		$ChatWindow.visible = false
	else:
		$ChatWindow.visible = true
		$ChatWindow/TextInput.grab_focus()


func output_text(answer):
	$ChatWindow/TextOutput.text += "A: {0}\n\n".format([answer])
	$ChatWindow/TextOutput.scroll_vertical = 10000

	$ChatWindow/TextInput.grab_focus()
