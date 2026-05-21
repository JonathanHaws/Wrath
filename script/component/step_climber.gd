extends Node3D ## Script enabling 3D Bodies to not get stuck on small ledges or bumpy terrain
## How far in front of the player the raycast to find the step is done
## Should usually be the radius of the collision shape of the body plus a little amount 0.01 - 0.1
@export var STEP_DISTANCE: float = .6 
@export var MAX_STEP_HEIGHT: float = 1.3 ## How much the player can step up
@export var MIN_STEP_HEIGHT: float = 0.05 ## Mimium step height
@export var BODY: CharacterBody3D ## The body that is moved up and retains velocity
@export var DEBUG_RAY: RayCast3D ## A way to visualize the step probe
var last_velocity: Vector3 = Vector3.ZERO
var accelerating: bool = false

## WIP Add step down logic
	
func is_accelerating() -> bool:
	var last_velocity_flat = Vector2(last_velocity.x, last_velocity.z)
	return last_velocity_flat.length() > STEP_DISTANCE

func try_step_up() -> void:		
	
	#print(BODY.get_slide_collision_count())
	#if not BODY.is_on_floor(): return 
	if BODY.velocity.y < 0: return
	if not BODY.is_on_wall(): return   
	if not is_accelerating(): return
	
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
		
		if not result: 
			#print('No surface to step on')
			return
		
		if abs(result.normal.y) <= 0.9: 
			#print('Not stepping. Surface to steep')
			return 
	
		var step = result.position.y - BODY.global_position.y	
		var new_pos = BODY.global_position
		new_pos.y += step
		var params := PhysicsTestMotionParameters3D.new()
		params.from = global_transform
		params.motion = new_pos - global_position
		if PhysicsServer3D.body_test_motion(BODY.get_rid(), params): 
			#print('Not stepping. New position would be inside wall... ')
			return	
			
		if step < MIN_STEP_HEIGHT: 	
			#print('Not stepping. Below minimum step height... Step should be handled by bottom roundness of the collider shape')
			return
			
		BODY.global_position.y += step
		BODY.velocity = last_velocity
		#print("Stepping up! " + str(step))	
		
func _physics_process(_delta: float) -> void:
	
	try_step_up()
	last_velocity = BODY.velocity
