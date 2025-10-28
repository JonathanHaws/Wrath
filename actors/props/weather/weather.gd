extends Node3D

#@export var particles: Node3D # Experimenting with potential fix to have particles follow player even when they move super fast
#@export var explosiveness_curve: Curve 
#@export var radius: float = 10

#var last_pos: Vector3


func _physics_process(_delta) -> void:
	#last_pos = global_transform.origin
	
	var active_camera = get_viewport().get_camera_3d()
	if active_camera and is_instance_valid(active_camera):
		global_transform = active_camera.global_transform


	#var distance_moved = global_transform.origin.distance_to(last_pos)
	
	#if particles:
		#particles.explosiveness = explosiveness_curve.sample(distance_moved)
		#print(particles.explosiveness)
