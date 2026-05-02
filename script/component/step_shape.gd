extends Area3D
@export var Body: CharacterBody3D
@export var MAX_STEP_HEIGHT: float = 3.0

func get_step_vector() -> Vector3:
	# Finds the closest free position vertically. Or returns 0 if theres no free position.
	# Potential Improvement / Flexiblity. Return 0 if the collision point normal is too steep.

	var space := get_world_3d().direct_space_state
	var shape_node: CollisionShape3D = Body.get_node("CollisionShape3D")
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape_node.shape
	query.collision_mask = Body.collision_mask
	query.exclude = [Body.get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = false
	
	var step := 0.05
	var max_steps := int(MAX_STEP_HEIGHT / step)
	var original := Body.global_position
	
	for i in max_steps:
		var offset := Vector3(0, step * (i + 1), 0)
		
		query.transform = Body.global_transform
		query.transform.origin = original + offset
		
		var hits := space.intersect_shape(query, 1)
		
		#print(hits[0].collider.name)
		#print(hits[0].collider.get_parent().name)
		
		if hits.is_empty():
			print(offset)
			return offset
	
	return Vector3.ZERO


func _physics_process(_delta: float) -> void:
	if not Body or Body.velocity.y > 1: return
	
	for collider in get_overlapping_bodies():
		if not collider is PhysicsBody3D: continue

		#print('overlapping')
		
		Body.position.y += 0.5
		#Body.global_position += get_step_vector()
		
		break
