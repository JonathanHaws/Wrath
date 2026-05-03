extends Area3D
@export var Body: CharacterBody3D
@export var MAX_STEP_HEIGHT: float = 1.5

func get_step_vector() -> Vector3:
	# Finds the closest free position vertically. Or returns 0 if theres no free position.
	# Potential Improvement / Flexiblity. Return 0 if the collision point normal is too steep.

	var space := get_world_3d().direct_space_state
	var shape_node: CollisionShape3D = get_node("CollisionShape3D")
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.transform = global_transform.translated(Vector3(0, MAX_STEP_HEIGHT, 0))
	query.collision_mask = Body.collision_mask
	query.exclude = [Body.get_rid()]
	query.motion = Vector3(0, -MAX_STEP_HEIGHT, 0)   # <- here

	var result := space.cast_motion(query)
	var safe := result[0]
	if safe <= 0.0: return Vector3.ZERO
	var step_up: float = MAX_STEP_HEIGHT * (1.0 - safe)
	#print(safe)-
	
	return Vector3(0, step_up, 0)


func _process(_delta: float) -> void:
	
	for collider in get_overlapping_bodies():
		if not collider is PhysicsBody3D: continue

		#print('overlapping')
		#Body.position.y += 0.5
		
		var step_vector = get_step_vector()
		
		if step_vector.length() > 0:
			Body.global_position += step_vector
			if "air_time" in Body: Body.air_time = 0
			if "velocity" in Body: Body.velocity.y = 0
		
		break
