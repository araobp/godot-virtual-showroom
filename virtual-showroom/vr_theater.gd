extends Node3D

const image_resources = [
	"IMG_0227_level.jpg",
	"IMG_0230_level.jpg",
	"IMG_0232_level.jpg",
	"IMG_0236_level.jpg",
	"IMG_0238_level.jpg"	,
	"IMG_0248_level.jpg",
	"IMG_0254_level.jpg",
	"IMG_0256_level.jpg",
	"PolyHaven_DresdenStation.jpg",
	"PolyHaven_HamburgStation.jpg",
	"PolyHaven_Hansaplatz.jpg"
]

const IMG_N = len(image_resources)

var img_idx = 0

# Gemini API Key
var GEMINI_API_KEY_FILE_PATH = "res://gemini_api_key_env.txt"
var GEMINI_API_KEY = ""


func get_environment_variable_from_file(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	content = content.strip_edges()
	return content


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_image(0)
	
	$HTTPRequest.request_completed.connect(_on_request_completed)
	
	GEMINI_API_KEY = get_environment_variable_from_file(GEMINI_API_KEY_FILE_PATH)	
	# print("Gemini API Key: " + GEMINI_API_KEY)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_image(img_idx):
	var material = StandardMaterial3D.new()
	var image = load("res://Panorama/" + image_resources[img_idx])
	material.albedo_texture = image
	material.emission_texture = image
	material.emission_enabled = true
	$SCREEN.set_surface_override_material(0, material)


func _on_button_image_backward_button_down() -> void:
	if img_idx > 0:
		img_idx -= 1

	set_image(img_idx)		


func _on_button_image_forward_button_down() -> void:
	if img_idx < IMG_N - 1:
		img_idx += 1

	set_image(img_idx)


func _on_button_describe_button_down() -> void:
			
	# Get the viewport's texture
	var viewport_texture = get_viewport().get_texture()

	# Get the image data	
	$CanvasLayer.hide()
	var image = viewport_texture.get_image()
	$CanvasLayer.show()

	# Resize the image (optional, but useful for smaller data)
	var viewport_size = get_viewport().size
	var img_width = 640
	var img_height = int(img_width * viewport_size[1]/viewport_size[0])
	image.resize(img_width, img_height)

	# Encode the image to Base64
	var b64image = Marshalls.raw_to_base64(image.save_jpg_to_buffer())

	_chat(b64image)
	

func _chat(b64image):
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
						"text": "Describe the image."
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
	
	print(json["candidates"][0]["content"]["parts"][0]["text"])
	
