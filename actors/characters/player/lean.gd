extends Node ## Script for adding leaning to 3d character controller (Only affects x and y axis)
## Warning may add better visual responsiveness but can change hitbox collisions so careful to keep subtle

## Determines how much lean weight is given to not just in the direction of velocity,
## But the difference or delta in velocity from this frame to the last (acceleration)
@export var ACCELERATION_WEIGHT = 8
@export var MAX_LEAN_FORWARD_DEGREES := 6.0  
@export var MAX_LEAN_SIDE_DEGREES := 8.0    
@export var LEAN_SPEED_FORWARD := 11.0
@export var LEAN_SPEED_SIDE := 5.0
@export var BODY: CharacterBody3D
@export var MESH: Node3D
var last_velocity := Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not BODY or not MESH: return

	#var keyboard_vector := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_forward", "keyboard_back")
	#var controller_vector := Input.get_vector("controller_left", "controller_right", "controller_forward", "controller_back")
	#var input_vector := keyboard_vector + controller_vector
	#var forward: Vector3 = -MESH.global_transform.basis.z

	var velocity_vector = BODY.velocity
	var acceleration_vector: Vector3 = BODY.velocity - last_velocity
	last_velocity = velocity_vector
	
	#var lean_vector = velocity_vector 
	#var lean_vector = acceleration_vector 
	var lean_vector = velocity_vector + (acceleration_vector * ACCELERATION_WEIGHT)

	var local_vel := MESH.to_local(BODY.global_transform.origin + lean_vector) - MESH.to_local(BODY.global_transform.origin)
	var target_rot := Vector3(
		clamp(local_vel.z * MAX_LEAN_FORWARD_DEGREES, -MAX_LEAN_FORWARD_DEGREES, MAX_LEAN_FORWARD_DEGREES), # X = forward/back
		0,                                                                                                  # Y = don't touch yaw
		clamp(-local_vel.x * MAX_LEAN_SIDE_DEGREES, -MAX_LEAN_SIDE_DEGREES, MAX_LEAN_SIDE_DEGREES)          # Z = left/right
	)

	MESH.rotation_degrees.x = lerp(MESH.rotation_degrees.x, target_rot.x, LEAN_SPEED_FORWARD * delta)
	MESH.rotation_degrees.z = lerp(MESH.rotation_degrees.z, target_rot.z, LEAN_SPEED_SIDE * delta)
