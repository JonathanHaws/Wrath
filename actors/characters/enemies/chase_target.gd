extends Node3D
@export_group("Chase")
@export var NAV_AGENT: NavigationAgent3D 
@export var BODY: Node3D ## The body that will move and collide
@export var SPEED = 9.0 ## speed in which target will give chase
@export var SPEED_MULTIPLIER: float = 1.0  ## Multiplier allowing certain animation to stop chase with easily animatable property
@export var MOVE_AND_SLIDE: bool = true ## Stop enemy from glitchy behavior by not chasing anymore once close enough defined by this area
@export var USE_GRAVITY: bool = true ## Stop enemy from using gravity (flying enemies)
@export var MESH_CHASE_VECTOR: bool = false ## use mesh forward instead of immeadite next navigation vector
@export var CHASE_VERTICALLY: bool = false ## If turned off velocity will only ever be applied on the x and z axes
@export var USE_PATHFINDING: bool = true

func _on_link_reached(link) -> void:
	var end_pos: Vector3 = link["link_exit_position"]
	#print(link) #Dictionary provided
	if BODY.is_on_floor():
		
		var delta: Vector3 = end_pos - BODY.global_position
		var horizontal_vec = Vector3(delta.x, 0, delta.z)
		var dir = horizontal_vec.normalized()

		# exact minimum y velocity needed to make jump assuming no obstructions (quadtratic kinematic)
		var g = -BODY.get_gravity().y
		var t = horizontal_vec.length() / SPEED  # horizontal travel time
		var jump_velocity = (delta.y / t) + 0.5 * g * t  # exact initial y velocity needed
		
		BODY.velocity.x = dir.x * SPEED
		BODY.velocity.z = dir.z * SPEED
		BODY.velocity.y = jump_velocity # do min
		
		#print(jump_velocity)

@export_subgroup("Target")
@export var TARGET_GROUP: String = "player"
@export var INPUT_READ_VELOCITY_MULTIPLIER: float = 0.0 ## Use targets body velocity to predict movement (Fire shot in front of player)
@export var MATCH_POSITION: bool = true ## Determines whether to match this nodes global position to target
func get_closest_from_group_3d(group: String) -> Node3D:
	var closest = null
	var min_dist = INF
	for node in get_tree().get_nodes_in_group(group):
		if not (node is CharacterBody3D or node is RigidBody3D):
			continue
		var dist = global_position.distance_squared_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = node
	return closest
func update_target_position(): ## keep node aligned to target
	if target == null:
		target = get_closest_from_group_3d(TARGET_GROUP)
	
	if target != null and MATCH_POSITION:
		if "velocity" in target:
			global_position = target.global_position + target.velocity * INPUT_READ_VELOCITY_MULTIPLIER
		else:
			global_position = target.global_position


@export_group("Tracking")
@export var MESH: Node3D ## The mesh that faces the target
@export var TRACKING_SPEED: float = 5.0 ## Degrees Per Second
@export var TRACKING_MULTIPLIER: float = 1.0 ## How Quickly rotation will match target
@export var FLIPPED_TRACKING: bool = false
func track(delta: float) -> void:
	if not MESH or not BODY or not target: return
	var initial_rotation = MESH.rotation
	var target_pos = target.global_transform.origin
	
	var dir = (target_pos - MESH.global_transform.origin).normalized()
	var up = Vector3.UP
	if abs(dir.dot(Vector3.UP)) > 0.99: # Avoid debug error 
		up = Vector3.FORWARD
	MESH.look_at(target_pos, up, FLIPPED_TRACKING)
		
	var target_rotation = MESH.rotation
	
	MESH.rotation = initial_rotation
	MESH.rotation.y = lerp_angle(initial_rotation.y, target_rotation.y, TRACKING_SPEED * TRACKING_MULTIPLIER * delta)

@export_group("Range")
@export var STOP_CHASE_AREA: Area3D ## What alerts enemies to give chase. If no area is specified they are omincient and always chase
@export var AWARENESS_AREA: Area3D ## How close they have to be to give chase. If none is specified its everywhere
@export var CHASER_GROUP: String = "chase" ## Specifies the group this NPCs body has to be apart of to give chase
var target: Node3D = null
func trigger_awareness() -> void:
	BODY.add_to_group(CHASER_GROUP)
	if target == null:
		target = get_closest_from_group_3d(TARGET_GROUP)
func _on_body_entered_stop_area(body: Node) -> void:
	if body.is_in_group(TARGET_GROUP):
		BODY.remove_from_group(CHASER_GROUP)
func _on_body_exited_stop_area(body: Node) -> void:
	if body.is_in_group(TARGET_GROUP):
		BODY.add_to_group(CHASER_GROUP)
func _on_body_entered_awareness(body: Node) -> void:
	if body.is_in_group(TARGET_GROUP):
		BODY.add_to_group(CHASER_GROUP)

func chase_target(speed: float = 0.0) -> void:
	if not target or not NAV_AGENT: return
	var chase_velocity: Vector3 
		
	if USE_PATHFINDING:
		if BODY.is_on_floor() and BODY.velocity.y < 6:
			NAV_AGENT.target_position = global_transform.origin
			chase_velocity = (NAV_AGENT.get_next_path_position() - BODY.global_transform.origin).normalized()
			if not CHASE_VERTICALLY: chase_velocity.y = 0
			BODY.velocity.x = chase_velocity.x * speed
			BODY.velocity.z = chase_velocity.z * speed 
	
	elif MESH_CHASE_VECTOR:
		chase_velocity = MESH.global_transform.basis.z.normalized()
		if not CHASE_VERTICALLY: chase_velocity.y = 0
		BODY.velocity.x = chase_velocity.x * speed
		BODY.velocity.z = chase_velocity.z * speed
		
	else:	
		chase_velocity = (global_position - BODY.global_position).normalized()
		if not CHASE_VERTICALLY: chase_velocity.y = 0
		BODY.velocity.x = chase_velocity.x * speed
		BODY.velocity.z = chase_velocity.z * speed 
	
func _ready() -> void:
	if STOP_CHASE_AREA:
		STOP_CHASE_AREA.body_entered.connect(_on_body_entered_stop_area)
		STOP_CHASE_AREA.body_exited.connect(_on_body_exited_stop_area)
		
	if AWARENESS_AREA:
		AWARENESS_AREA.body_entered.connect(_on_body_entered_awareness)
		
	if NAV_AGENT:
		NAV_AGENT.link_reached.connect(_on_link_reached)

func _physics_process(delta: float) -> void:
	
	update_target_position()	
	track(delta)
	
	if not BODY: return
	
	chase_target(SPEED * SPEED_MULTIPLIER)
		
	if USE_GRAVITY: 
		if not BODY.is_on_floor(): 
			BODY.velocity += BODY.get_gravity() * delta

	if not BODY.is_in_group(CHASER_GROUP):
		BODY.velocity.x = 0
		BODY.velocity.z = 0
	
	if MOVE_AND_SLIDE: 
		BODY.move_and_slide()
	
	
