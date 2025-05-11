extends Node3D
@export var target_group: String
var target: Node3D = null

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
		target = get_closest_from_group_3d(target_group)
	if target != null:
		global_position = target.global_position
