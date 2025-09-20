extends Node3D

func _ready():
	await get_tree().process_frame
	if not is_instance_valid(self): return
	
	var puddle_forward = -global_transform.basis.z.normalized()  # forward vector
	var target_forward = Vector3(0, 1, 0)  # want it to be pointing up
	
	if puddle_forward.dot(target_forward) < 0.99:  # not roughly facing up so delete
		queue_free()
	
	global_transform = Transform3D(Basis(), global_position)
	
	
