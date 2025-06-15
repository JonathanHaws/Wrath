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
@export var STOP_CHASE_AREA: Area3D
var target: Node3D = null
var should_chase: bool = true

func track(delta: float) -> void:
	if not MESH or not BODY or not target: return
	
	var initial_basis = MESH.global_transform.basis
	if abs((global_position - MESH.global_transform.origin).normalized().dot(Vector3.UP)) > 0.999: return #rotation vectors too similar? exit to avoid error 
	if MESH.global_transform.origin.distance_to(target.global_position) < 0.001: return #target and self too similar? exit to avoid error 
	
	MESH.look_at(global_position, Vector3.UP, FLIPPED_TRACKING)
	var target_basis = MESH.global_transform.basis
	target_basis.y = initial_basis.y
	target_basis = target_basis.orthonormalized() 
	MESH.global_transform.basis = initial_basis.slerp(target_basis, TRACKING_SPEED * TRACKING_MULTIPLIER * delta).orthonormalized()

func move_to_target(delta: float, speed: float = 0.0, scalar: Vector3 = Vector3(1, 0, 1)) -> void:
	if not target or not NAV_AGENT: return
	NAV_AGENT.target_position = global_transform.origin
	var navigation_velocity = (NAV_AGENT.get_next_path_position() - BODY.global_transform.origin).normalized() * scalar 
	BODY.global_position += navigation_velocity * speed * delta

func get_closest_from_group_3d(group: String) -> Node3D:
	var closest = null
	var min_dist = INF
	for node in get_tree().get_nodes_in_group(group):
		if not node is Node3D:
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

func _ready() -> void:
	if STOP_CHASE_AREA:
		STOP_CHASE_AREA.body_entered.connect(_on_body_entered_stop_area)
		STOP_CHASE_AREA.body_exited.connect(_on_body_exited_stop_area)

func _physics_process(delta: float) -> void:
	if should_chase:
		move_to_target(delta, SPEED * SPEED_MULTIPLIER)
	
	if MOVE_AND_SLIDE: 
		BODY.move_and_slide()
	
	if not BODY.is_on_floor(): BODY.velocity += BODY.get_gravity() * delta
	
	track(delta)
	
	if target == null:
		target = get_closest_from_group_3d(TARGET_GROUP)
	if target != null:
		global_position = target.global_position
