extends Node3D

var models

var idx = 0
var N


func _make_visible(idx_):
	for i in N:
		if i == idx_:
			models[i].visible = true
			models[i].sit_down()
			#models[i].sit_down()			
		else:
			models[i].visible = false
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	models = get_children()
	N = len(models)
	
	_make_visible(idx)
			
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func next_model() -> void:
	if idx < N - 1:
		idx += 1
	_make_visible(idx)


func prev_model() -> void:
	if idx > 0:
		idx -= 1
	_make_visible(idx)
