extends Node3D

const IMAGES = [
	["Rinko Park, Yokohama", "IMG_0227_level.jpg"],
	["Yamashita Rinko Line Promenade, Yokohama", "IMG_0230_level.jpg"],
	["Osanbashi Yokohama International Passenger Terminal, Yokohama", "IMG_0232_level.jpg"],
	["Osanbashi Yokohama International Passenger Terminal, Yokohama", "IMG_0236_level.jpg"],
	["Osanbashi Yokohama International Passenger Terminal, Yokohama",  "IMG_0238_level.jpg"],
	["Takanawa Gateway Station, Tokyo", "IMG_0248_level.jpg"],
	["Takanawa Gateway Station, Tokyo", "IMG_0254_level.jpg"],
	["Takanawa Gateway Station, Tokyo", "IMG_0256_level.jpg"],
	["Dresden Central Station, Dresden, Germany", "PolyHaven_DresdenStation.jpg"],
	["Hamburg Central Station, Hamburg, Germany", "PolyHaven_HamburgStation.jpg"],
	["Hansaplatz, Hamburg, Germany", "PolyHaven_Hansaplatz.jpg"]
]

const IMG_N = len(IMAGES)

var img_idx = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_image(0)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_image(idx):
	var material = StandardMaterial3D.new()
	var image = load("res://Panorama/" + IMAGES[idx][1])
	material.albedo_texture = image
	material.emission_texture = image
	material.emission_enabled = true
	$SCREEN.set_surface_override_material(0, material)


func image_place():
	return IMAGES[img_idx][0]

func _on_button_image_backward_button_down() -> void:
	if img_idx > 0:
		img_idx -= 1

	set_image(img_idx)		


func _on_button_image_forward_button_down() -> void:
	if img_idx < IMG_N - 1:
		img_idx += 1

	set_image(img_idx)
