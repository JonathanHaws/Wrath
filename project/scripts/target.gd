extends Node3D
@export var TARGET_GROUP: String = "player"
@export var NAV_REGION: NavigationRegion3D 
@export var NAV_AGENT: NavigationAgent3D
@export var TRACKING_SPEED: float = 5.0
@export var TRACKING_MULTIPLIER: float = 1.0
var target: Node3D = null
var target_direction = Vector3.ZERO

#func track_towards_direction(delta: float) -> void:
	#if target_direction.length_squared() < 0.0001: return
	#if target_direction.normalized().is_equal_approx(Vector3.ZERO): return
	#var target_basis = Basis.looking_at(target_direction, Vector3.UP)
	#var interpolated_basis = MESH.global_transform.basis.slerp(target_basis, TRACKING_SPEED * TRACKING_MULTIPLIER * delta)
	#MESH.global_transform.basis = interpolated_basis.orthonormalized()

func move_to_target(delta: float, scene_root: Node3D, speed: float = 0.0, scalar: Vector3 = Vector3(1, 0, 1)) -> void:

	NAV_AGENT.target_position = global_transform.origin
	var navigation_velocity = (NAV_AGENT.get_next_path_position() - scene_root.global_transform.origin).normalized() * scalar 
	scene_root.global_position += navigation_velocity * speed * delta

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
	
func _process(_delta):
	if target == null:
		target = get_closest_from_group_3d(TARGET_GROUP)
	if target != null:
		global_position = target.global_position
