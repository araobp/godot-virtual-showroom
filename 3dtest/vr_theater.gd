extends Node3D

var image_resources = [
	"IMG_0227_level.jpg",
	"IMG_0230_level.jpg",
	"IMG_0232_level.jpg",
	"IMG_0236_level.jpg",
	"IMG_0238_level.jpg"	
]

var idx = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_image(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_image(idx):
	var material = StandardMaterial3D.new()
	var image = load("res://Panorama/" + image_resources[idx])
	material.albedo_texture = image
	material.emission_texture = image
	material.emission_enabled = true
	$SCREEN.set_surface_override_material(0, material)

func _on_button_image_backward_button_down() -> void:
	if idx > 0:
		idx -= 1

	set_image(idx)		
	
func _on_button_image_forward_button_down() -> void:
	if idx < 4:
		idx += 1

	set_image(idx)
