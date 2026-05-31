extends Node3D ## Script enabling 3D Bodies to not get stuck on small ledges or bumpy terrain
## Avoids stepping up just to instantly fall back down because of walking too parallel to the step, instead of right into it. 
## BODY is required to have a [member raw_velocity] property set before calling [method move_and_slide]. So it can calculate the alignment
@export_range(0.0, 1.0, 0.01) var MIN_STEP_ALIGNMENT: float = 0.25 
@export var MAX_STEP_HEIGHT: float = 1.3 ## How much the player can step up
@export var MIN_STEP_HEIGHT: float = 0.05 ## Mimium step height. Steps smaller then this should be sufficently handled by bottom roundness of capsule collider
@export var BODY: CharacterBody3D ## The body that is moved up and retains velocity
var last_velocity: Vector3 = Vector3.ZERO

func body_would_clip(body: CharacterBody3D, target_position: Vector3) -> bool:
	var params := PhysicsTestMotionParameters3D.new()
	params.from = body.global_transform
	params.motion = target_position - body.global_position
	return PhysicsServer3D.body_test_motion(body.get_rid(), params)

func raycast(from: Vector3, to: Vector3) -> Dictionary:
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = BODY.collision_mask
	query.exclude = [BODY.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)

func try_step_down() -> void: # wip
	pass

func try_step_up() -> void:		
	
	#print(BODY.get_slide_collision_count())
	#if not BODY.is_on_floor(): return 
	if BODY.velocity.y < 0: return
	if not BODY.is_on_wall(): return   
	
	for i in BODY.get_slide_collision_count():
		
		var collision = BODY.get_slide_collision(i)
		var collision_position = collision.get_position()	
		var collision_normal = collision.get_normal()

		var diff = collision_position - BODY.global_position
		var diff_small_margin = (diff.normalized() * diff.length() * 1.05)

		# raycast down
		var ray_end = BODY.global_position
		ray_end += diff_small_margin
		ray_end.y = BODY.global_position.y
		var ray_start = ray_end
		ray_start.y += MAX_STEP_HEIGHT
		var result = raycast(ray_start, ray_end)

		if not result: return # No surface to step on
		
		var step = result.position.y - BODY.global_position.y	
		var new_pos = BODY.global_position + (Vector3.UP * step)
		
		if step < MIN_STEP_HEIGHT: return # Step not big enough
		if abs(result.normal.y) <= 0.9: return # Surface to steep
		if body_would_clip(BODY, new_pos): return # New position would be inside wall	
		
		if "raw_velocity" in BODY:
			var real_velocity = BODY.raw_velocity
			var velocity_flat = Vector3(real_velocity.x, 0, real_velocity.z).normalized()
			var normal_flat = Vector3(collision_normal.x, 0, collision_normal.z).normalized()
			var alignment = velocity_flat.dot(-normal_flat)	
			if alignment < 0.2: # Walking too parallel to a step. If climbed up will just isntantly fall back down. Skipping...
				#print(alignment)
				return
		
		BODY.global_position.y += step
		BODY.velocity = last_velocity
		#print("Stepping up! " + str(step))	
	
func _physics_process(_delta: float) -> void:
	
	#print(BODY.get_position_delta())
	#try_step_down()
	try_step_up()
	last_velocity = BODY.velocity
