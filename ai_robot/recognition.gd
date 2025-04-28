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

func set_image(i):
	var material = StandardMaterial3D.new()
	var image = load("res://Images/" + IMAGES[i])
	material.albedo_texture = image
	material.emission_texture = image
	material.emission_enabled = true
	$LargeDisplay/Screen.set_surface_override_material(0, material)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_image(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func next_image():
	if idx < len(IMAGES) - 1:
		idx += 1
		set_image(idx)

func prev_image():
	if idx > 0:
		idx -= 1
		set_image(idx)
