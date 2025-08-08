extends Node
@export var mesh_node: Node3D
@export var target_squash_scale: float = 1.0
@export var speed: float = 0.09

func settle(MESH: Node3D, delta: float, squash_speed: float = 0.09, target_squash: float = 1.0) -> void:
	if delta == 0: return
	var current_squash = MESH.scale.y
	current_squash = lerp(current_squash, target_squash, (delta * squash_speed) * (1.0 / delta))
	var squash_compensation = 1 - ((current_squash - 1) * .5)
	MESH.scale.y = current_squash
	MESH.scale.x = squash_compensation
	MESH.scale.z = squash_compensation

func squish(squash_factor: float = 0.0, MESH: Node3D = null, rest_scale: float = 1.0) -> void:
	MESH = MESH if MESH else mesh_node
	if not MESH: return
	MESH.scale.y = rest_scale - squash_factor
	MESH.scale.x = 1.0 - (squash_factor * 0.5)
	MESH.scale.z = 1.0 - (squash_factor * 0.5)
	
func _process(_delta: float) -> void:
	if mesh_node: settle(mesh_node, _delta, speed, target_squash_scale)
