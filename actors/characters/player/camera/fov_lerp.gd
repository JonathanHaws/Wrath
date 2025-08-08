extends Node
@export var camera_node: Camera3D
@export var lerp_speed: float = 5.0
@export var target_fov: float = 80.0

func _process(delta):
	if camera_node == null:
		return
	camera_node.fov = lerp(camera_node.fov, target_fov, lerp_speed * delta)
