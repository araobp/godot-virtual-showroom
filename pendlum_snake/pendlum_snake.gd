extends Node3D

var rigid_bodies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rigid_bodies = [
	$Pendlums/RigidBody3D_P1,
	$Pendlums/RigidBody3D_P2,
	$Pendlums/RigidBody3D_P3,
	$Pendlums/RigidBody3D_P4,
	$Pendlums/RigidBody3D_P5,
	$Pendlums/RigidBody3D_P6,
	$Pendlums/RigidBody3D_P7,
	$Pendlums/RigidBody3D_P8,
	$Pendlums/RigidBody3D_P9,
	$Pendlums/RigidBody3D_P10,
	$Pendlums/RigidBody3D_P11,
	$Pendlums/RigidBody3D_P12,
	$Pendlums/RigidBody3D_P13,
	$Pendlums/RigidBody3D_P14,
	$Pendlums/RigidBody3D_P15
	]
	
	for rb in rigid_bodies:
		rb.freeze = true
		print(rb.rotation.z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start():
	for rb in rigid_bodies:
		rb.freeze = false
	get_tree().paused = false

func pause():
	get_tree().paused = true

func resume():
	get_tree().paused = false

func reset():
	get_tree().reload_current_scene()
