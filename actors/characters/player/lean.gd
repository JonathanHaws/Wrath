extends Node
@export var BODY: CharacterBody3D
@export var MESH: Node3D
@export var LEAN_SPEED := 8.0
@export var MAX_LEAN_ANGLE := 0.0 # degrees
var last_velocity := Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not BODY or not MESH: return

	var delta_velocity: Vector3 = BODY.velocity - last_velocity
	last_velocity = BODY.velocity
	
	var forward: Vector3 = -MESH.global_transform.basis.z
	var lean_amount: float = delta_velocity.dot(forward)

	var target_lean: float = clamp(-lean_amount * MAX_LEAN_ANGLE, -MAX_LEAN_ANGLE, MAX_LEAN_ANGLE)

	var rot: Vector3 = MESH.rotation_degrees
	rot.x = lerp(rot.x, target_lean, LEAN_SPEED * delta)
	MESH.rotation_degrees = rot

	
