extends Node3D


const ColorTempToRGB = {
	"daylight": Color(255/255.0, 255/255.0, 251/255.0),
	"cool": Color(50/255.0, 50/255.0, 255/255.0),
	"warm": Color(255/255.0, 50/255.0, 50/255.0)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_light_values({"brightness": 5.0, "color_temp": "daylight"})
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func set_light_values(args) -> void:
	var brightness = args["brightness"]
	var color_temp = args["color_temp"]
	var material = $Building/Light.mesh.material
	material.emission_energy_multiplier = brightness
	material.emission = ColorTempToRGB[color_temp]
