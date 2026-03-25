extends Node
@export var meshes: Array[Node3D]
@export var target_squash_scale: float = 1.0
@export var speed: float = 0.08

func settle(MESH: Node3D, delta: float, squash_speed: float = 0.09, target_squash: float = 1.0) -> void:
	if delta == 0: return
	var current_squash = MESH.scale.y
	current_squash = lerp(current_squash, target_squash, (delta * squash_speed) * (1.0 / delta))
	var squash_compensation = 1 - ((current_squash - 1) * .5)
	MESH.scale.y = current_squash
	MESH.scale.x = squash_compensation
	MESH.scale.z = squash_compensation

func squish(factor: float = 0.0) -> void:
	for mesh in meshes:
		if not mesh: continue
		mesh.scale = Vector3(1.0 - factor * 0.5, 1.0 - factor, 1.0 - factor * 0.5)
	
func _physics_process(delta: float) -> void:
	for mesh in meshes:
		if mesh: settle(mesh, delta)
