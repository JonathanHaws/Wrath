extends Node3D

@export var offset_up: Vector3 = Vector3(0, 0.1, 0) ## Offset from collision point up to make sure ray doesn't gltich
@export var ray_down: Vector3 = Vector3(0, -.2, 0) ## If no floor beneath destroy

func _ready():
	await get_tree().process_frame
	
	global_transform = Transform3D(Basis(), global_position + offset_up)
	
	var space = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(global_position, global_position + ray_down)
	params.collide_with_bodies = true
	params.collide_with_areas = false
	var hit = space.intersect_ray(params)
	if not hit:
		queue_free()
