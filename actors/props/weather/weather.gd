extends Node3D
## Convert process material into shader material so that
## wrapping can be based on emmison shape. So it still looks dense while moving
## Look inside script for code snippet to use inside shader 

#// Use me at the end of process in the shader material to wrap 
#// CUSTOM WRAPPING / TELEPORT INSIDE EMISSON SHAPE IF THE PARTICLE HAS GONE OUT OF BOUNDS
#vec3 p = TRANSFORM[3].xyz;
#vec3 lp = inverse(mat3(EMISSION_TRANSFORM)) * (p - EMISSION_TRANSFORM[3].xyz);
#while (abs(lp.x) > emission_box_extents.x ||
	   #abs(lp.y) > emission_box_extents.y ||
	   #abs(lp.z) > emission_box_extents.z) {
	#if (lp.x > emission_box_extents.x) lp.x -= 2.0 * emission_box_extents.x;
	#if (lp.x < -emission_box_extents.x) lp.x += 2.0 * emission_box_extents.x;
	#if (lp.y > emission_box_extents.y) lp.y -= 2.0 * emission_box_extents.y;
	#if (lp.y < -emission_box_extents.y) lp.y += 2.0 * emission_box_extents.y;
	#if (lp.z > emission_box_extents.z) lp.z -= 2.0 * emission_box_extents.z;
	#if (lp.z < -emission_box_extents.z) lp.z += 2.0 * emission_box_extents.z;}
#TRANSFORM[3].xyz = (EMISSION_TRANSFORM * vec4(lp, 1.0)).xyz;

@export var particles: GPUParticles3D 
@export var depth: float = 5.5 ## How far the emisson box extends forward into the cameras frustum 
@export var offset: Vector3 = Vector3(0, 0, 8.0) ## Used to set the shapes
var emission_box_size: Vector3
var last_viewport_size: Vector2

@export_group("Debug")
@export var debug_node: Node ## Used for visualizing culling and wrapping done by shader
@export var debug_shape: Node3D  ## Used for visualizing the shape relative to the camera
@export var debug_cam: Node3D  ## Used for visualizing the camera relative to the shape

func update_position_and_emission() -> void:
	var cam = get_viewport().get_camera_3d()
	if not cam or not is_instance_valid(cam): return

	var viewport_size:= get_viewport().get_visible_rect().size
	if viewport_size != last_viewport_size:
		last_viewport_size = viewport_size
		
		var aspect_ratio = viewport_size.x / viewport_size.y # Also near plane width
		var half_middle_height = (depth + offset.z) * tan(deg_to_rad(cam.fov * 0.5))
		# Scince near plane height is 1. ^^^ This is also a multipler for different frustum slices
		emission_box_size = Vector3 ((aspect_ratio *.5) * half_middle_height, half_middle_height * 0.5, depth)
		
		var material := particles.process_material as ShaderMaterial
		material.set_shader_parameter("emission_box_extents", emission_box_size)
	
	global_transform = cam.global_transform # start at camera
	global_transform.origin -= cam.global_transform.basis * (Vector3(0, 0, emission_box_size.z * 0.5) + offset)  #move forward half the emisson box

	if debug_node and debug_node.visible:
		debug_node.global_position = cam.global_position
		debug_node.global_position -= cam.global_transform.basis.z * 5
		debug_node.global_rotation = (cam.global_rotation * 2)
		debug_node.scale = Vector3(0.3, 0.3, 0.3)
		if debug_shape:
			debug_shape.position = Vector3(0, 0, 0.0 - (emission_box_size.z * 0.5)) - offset
			debug_shape.scale = emission_box_size 
		if debug_cam:
			debug_cam.scale.x = emission_box_size.y / emission_box_size.x
	
	#print(emission_box_size)

func _ready() -> void:
	update_position_and_emission()

func _process(_delta: float) -> void:
	update_position_and_emission()
