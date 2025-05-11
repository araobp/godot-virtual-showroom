extends Node3D

const IMAGES = [
	"0_iso-republic-cat-bathing.jpg",
	"1_iso-republic-dog-beagle-floppy-ears.jpg",
	"2_sheep-field.jpg",
	"3_picography-vintage-new-york-cityscape-skyscraper-building-usa-1.jpg",
	"4_iso-republic-golden-gate-bridge-02.jpg",
	"5_berlin-palace.jpg",
	"6_iso-republic-neuschwanstein-castle.jpg",
	"7_picography-red-and-green-apple-1.jpg"
]

var idx = 0
var material

func _set_image_to_screen(image_texture):
	material.albedo_texture = image_texture
	material.emission_texture = image_texture
	material.emission_enabled = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material = StandardMaterial3D.new()
	$LargeDisplay/Screen.set_surface_override_material(0, material)
	set_image(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://menu.tscn")


func next_image():
	if idx < len(IMAGES) - 1:
		idx += 1
		set_image(idx)


func prev_image():
	if idx > 0:
		idx -= 1
		set_image(idx)


func set_image(i):
	var image_texture = load("res://Images/" + IMAGES[i])
	_set_image_to_screen(image_texture)


func capture_image_from_robot_camera():
	var image = $SubViewportContainer_Robot/SubViewport_Robot.get_viewport().get_texture().get_image()
	# Encode the image to Base64
	var b64image = Marshalls.raw_to_base64(image.save_jpg_to_buffer())

	return b64image

func set_image_from_robot_camera_to_screen():
	var image = $SubViewportContainer_Robot/SubViewport_Robot.get_viewport().get_texture().get_image()
	var image_texture = ImageTexture.create_from_image(image)
	_set_image_to_screen(image_texture)
	
func start_point_animation():
	$SubViewportContainer_Robot/SubViewport_Robot/Robot.point()
