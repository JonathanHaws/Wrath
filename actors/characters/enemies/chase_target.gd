extends Node3D
@export_group("Navigation")
@export var TARGET_GROUP: String = "player"
@export var BODY: Node3D ## The body that will move and collide
@export var MESH: Node3D ## The mesh that faces the target
@export var NAV_AGENT: NavigationAgent3D 
@export var INPUT_READ_VELOCITY_MULTIPLIER: float = 0.0 ## Use targets body velocity to predict movement (Fire shot in front of player)
@export var MATCH_POSITION: bool = true ## Determines whether to match this nodes global position to target

@export_group("Tracking")
@export var TRACKING_SPEED: float = 5.0 ## Degrees Per Second
@export var TRACKING_MULTIPLIER: float = 1.0 ## How Quickly rotation will match target
@export var FLIPPED_TRACKING: bool = false

@export_group("Chase")
@export var USE_PATHFINDING: bool = true
@export var MOVE_AND_SLIDE: bool = true ## Stop enemy from glitchy behavior by not chasing anymore once close enough defined by this area
@export var USE_GRAVITY: bool = true ## Stop enemy from using gravity (flying enemies)
@export var MESH_CHASE_VECTOR: bool = false ## use mesh forward instead of immeadite next navigation vector
@export var CHASE_VERTICALLY: bool = false ## If turned off velocity will only ever be applied on the x and z axes
@export var SPEED = 9.0 ## speed in which target will give chase
@export var SPEED_MULTIPLIER: float = 1.0  ## Multiplier allowing certain animation to stop chase with easily animatable property

@export_subgroup("Range")
@export var STOP_CHASE_AREA: Area3D ## What alerts enemies to give chase. If no area is specified they are omincient and always chase
@export var AWARENESS_AREA: Area3D ## How close they have to be to give chase. If none is specified its everywhere

var target: Node3D = null
var should_chase: bool = true

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

func chase_target(speed: float = 0.0) -> void:
	if not target or not NAV_AGENT: return
	var chase_velocity: Vector3 
	
	if USE_PATHFINDING:
		NAV_AGENT.target_position = global_transform.origin
		chase_velocity = (NAV_AGENT.get_next_path_position() - BODY.global_transform.origin).normalized()
	else:	
		chase_velocity = (global_position - BODY.global_position).normalized() 
	
	if not CHASE_VERTICALLY:
		chase_velocity.y = 0
		chase_velocity = chase_velocity.normalized()
	
	if MESH_CHASE_VECTOR:
		chase_velocity = MESH.global_transform.basis.z.normalized()
	
	BODY.velocity.x = chase_velocity.x * speed
	BODY.velocity.z = chase_velocity.z * speed

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

func trigger_awareness() -> void:
	should_chase = true
	if target == null:
		target = get_closest_from_group_3d(TARGET_GROUP)

func _on_body_entered_stop_area(body: Node) -> void:
	if body.is_in_group(TARGET_GROUP):
		should_chase = false

func _on_body_exited_stop_area(body: Node) -> void:
	if body.is_in_group(TARGET_GROUP):
		should_chase = true

func _on_body_entered_awareness(body: Node) -> void:
	if body.is_in_group(TARGET_GROUP):
		should_chase = true

func _ready() -> void:
	if STOP_CHASE_AREA:
		STOP_CHASE_AREA.body_entered.connect(_on_body_entered_stop_area)
		STOP_CHASE_AREA.body_exited.connect(_on_body_exited_stop_area)
		
	if AWARENESS_AREA:
		should_chase = false
		AWARENESS_AREA.body_entered.connect(_on_body_entered_awareness)

func _physics_process(delta: float) -> void:
	
	if BODY: 
		
		if USE_GRAVITY: if not BODY.is_on_floor(): BODY.velocity += BODY.get_gravity() * delta

		BODY.velocity.x = 0
		BODY.velocity.z = 0

		if should_chase:
			chase_target(SPEED * SPEED_MULTIPLIER)
		
		if MOVE_AND_SLIDE: 
			BODY.move_and_slide()
		
		track(delta)
	
	if target == null:
		target = get_closest_from_group_3d(TARGET_GROUP)
	
	#print(BODY.velocity.y)
	
	if target != null and MATCH_POSITION:
		if "velocity" in target:
			global_position = target.global_position + target.velocity * INPUT_READ_VELOCITY_MULTIPLIER
		else:
			global_position = target.global_position
