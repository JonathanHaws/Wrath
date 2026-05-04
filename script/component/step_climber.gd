extends Node3D ## Script enabling 3D Bodies to not get stuck on small ledges or bumpy terrain
## How far in front of the player the raycast to find the step is done
## Should usually be the radius of the collision shape of the body plus a little amount 0.01 - 0.1
@export var STEP_DISTANCE: float = .6 
@export var MAX_STEP_HEIGHT: float = 1.3 ## How much the player can step up
@export var BODY: CharacterBody3D ## The body that is moved up and retains velocity
@export var DEBUG_RAY: RayCast3D ## A way to visualize the step probe
var last_velocity: Vector3 = Vector3.ZERO

func is_moving_horizontally(velocity: Vector3) -> bool:
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0
	return horizontal_velocity.length() > 0.01		
		
func try_step_up() -> void:		
	
	if not BODY.is_on_wall(): return  
	#if not BODY.is_on_floor(): return  
	if not is_moving_horizontally(last_velocity): return
	#print(BODY.get_slide_collision_count())
	
	for i in BODY.get_slide_collision_count():
		
		var collision = BODY.get_slide_collision(i)
		var collision_position = collision.get_position()
		var space_state = get_world_3d().direct_space_state	
		
		var ray_end = BODY.global_position
		var diff = collision_position - BODY.global_position
		diff.y = 0
		var normalized_difference = diff.normalized()
		ray_end += (normalized_difference * STEP_DISTANCE)
		ray_end.y = BODY.global_position.y
		
		var ray_start = ray_end
		ray_start.y += MAX_STEP_HEIGHT
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.collision_mask = BODY.collision_mask
		query.exclude = [BODY.get_rid()]
		var result = space_state.intersect_ray(query)
		
		if DEBUG_RAY:
			DEBUG_RAY.visible = true
			DEBUG_RAY.global_position = ray_start
			DEBUG_RAY.target_position = ray_end - ray_start
		
		if not result: return
		if abs(result.normal.y) <= 0.9: return # dont step if too steep 
		
		var step = result.position.y - BODY.global_position.y	
			
		## Return if would be in collision
		var new_pos = BODY.global_position
		new_pos.y += step
		var params := PhysicsTestMotionParameters3D.new()
		params.from = global_transform
		params.motion = new_pos - global_position
		if PhysicsServer3D.body_test_motion(BODY.get_rid(), params): 
			#print('colliding')
			return	
			
		BODY.global_position.y += step
		BODY.velocity = last_velocity
		#print("Stepping up!" + str(step))	
		
func _physics_process(_delta: float) -> void:
	
	try_step_up()
	last_velocity = BODY.velocity
