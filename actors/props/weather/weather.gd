extends Node3D

func _physics_process(_delta) -> void:
	var active_camera = get_viewport().get_camera_3d()
	if active_camera and is_instance_valid(active_camera):
		global_transform = active_camera.global_transform
