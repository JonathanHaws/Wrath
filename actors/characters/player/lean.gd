extends Node
@export var BODY: CharacterBody3D
@export var MESH: Node3D
@export var LEAN_SPEED := 8.0
@export var MAX_LEAN_ANGLE := 5.0 # degrees
var last_velocity := Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not BODY or not MESH: return

	#var delta_velocity: Vector3 = BODY.velocity - last_velocity
	last_velocity = BODY.velocity
	
	#var keyboard_vector := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_forward", "keyboard_back")
	#var controller_vector := Input.get_vector("controller_left", "controller_right", "controller_forward", "controller_back")
	#var input_vector := keyboard_vector + controller_vector
	
	var forward: Vector3 = -MESH.global_transform.basis.z
	
	#if input_vector.length() > 1.0:
		#forward = forward
	#else:
		#forward = -forward

	var target_lean = clamp(BODY.velocity.dot(forward) * MAX_LEAN_ANGLE, -MAX_LEAN_ANGLE, MAX_LEAN_ANGLE)

	var rot := MESH.rotation_degrees
	rot.x = lerp(rot.x, -target_lean, LEAN_SPEED * delta)
	MESH.rotation_degrees = rot

	
