extends Node3D
@export var TARGET_GROUP: String = "player"
@export var NAV_AGENT: NavigationAgent3D
@export var TRACKING_SPEED: float = 5.0
@export var TRACKING_MULTIPLIER: float = 1.0
@export var SPEED = 9.0
@export var SPEED_MULTIPLIER: float = 1.0
@export var FLIPPED_TRACKING: bool = false
@export var MESH: Node3D
@export var BODY: Node3D
@export var MOVE_AND_SLIDE: bool = true
## Stop enemy from glitchy behavior by not chasing anymore once close enough defined by this area
@export var STOP_CHASE_AREA: Area3D
## What alerts enemies to give chase. If no area is specified they are omincient and always chase
@export var AWARENESS_AREA: Area3D
var target: Node3D = null
var should_chase: bool = true

func track(delta: float) -> void:
	if not MESH or not BODY or not target: return
	
	var initial_rotation = MESH.rotation
	
	var target_pos = target.global_transform.origin
	
	if not MESH.global_transform.origin.is_equal_approx(target_pos):
		MESH.look_at(target_pos, Vector3.UP, FLIPPED_TRACKING) 
	var target_rotation = MESH.rotation
	
	MESH.rotation = initial_rotation
	MESH.rotation.y = lerp_angle(initial_rotation.y, target_rotation.y, TRACKING_SPEED * TRACKING_MULTIPLIER * delta)

func move_to_target(speed: float = 0.0, scalar: Vector3 = Vector3(1, 0, 1)) -> void:
	if not target or not NAV_AGENT: return
	NAV_AGENT.target_position = global_transform.origin
	var path_vector = NAV_AGENT.get_next_path_position() - BODY.global_transform.origin
	if path_vector.length_squared() < 0.0001: return
	var navigation_velocity = (path_vector).normalized() * scalar 
	
	BODY.velocity.x = navigation_velocity.x * speed
	BODY.velocity.z = navigation_velocity.z * speed

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
		
		if not BODY.is_on_floor(): BODY.velocity += BODY.get_gravity() * delta

		BODY.velocity.x = 0
		BODY.velocity.z = 0

		if should_chase:
			move_to_target(SPEED * SPEED_MULTIPLIER)
		
		if MOVE_AND_SLIDE: 
			BODY.move_and_slide()
		
		track(delta)
	
	if target == null:
		target = get_closest_from_group_3d(TARGET_GROUP)
	if target != null:
		global_position = target.global_position
