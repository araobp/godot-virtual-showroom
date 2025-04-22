extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Wave Hip Hop Dance2/AnimationPlayer".get_animation("mixamo_com").loop_mode=(Animation.LOOP_LINEAR)
	$"Wave Hip Hop Dance2/AnimationPlayer".play("mixamo_com")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
