extends Node3D

var rigid_bodies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rigid_bodies = [
	$Pendulums/RigidBody3D_P1,
	$Pendulums/RigidBody3D_P2,
	$Pendulums/RigidBody3D_P3,
	$Pendulums/RigidBody3D_P4,
	$Pendulums/RigidBody3D_P5,
	$Pendulums/RigidBody3D_P6,
	$Pendulums/RigidBody3D_P7,
	$Pendulums/RigidBody3D_P8,
	$Pendulums/RigidBody3D_P9,
	$Pendulums/RigidBody3D_P10,
	$Pendulums/RigidBody3D_P11,
	$Pendulums/RigidBody3D_P12,
	$Pendulums/RigidBody3D_P13,
	$Pendulums/RigidBody3D_P14,
	$Pendulums/RigidBody3D_P15
	]
	
	for rb in rigid_bodies:
		rb.freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start():
	for rb in rigid_bodies:
		rb.freeze = false
	get_tree().paused = false


func toggle_pause():
	var tree = get_tree()
	if !tree.paused:
		tree.paused = true
		$CanvasLayer/ButtonTogglePause.text = "Resume"
	else:
		tree.paused = false
		$CanvasLayer/ButtonTogglePause.text = "Pause"


func reset():
	get_tree().reload_current_scene()
