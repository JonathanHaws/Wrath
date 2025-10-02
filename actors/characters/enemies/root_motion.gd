extends Node3D
@export var SKELETAL_ANIMATION_PLAYER: AnimationPlayer 
@export var SKELETON: Node3D
@export var MESH: Node3D
@export var SCENE_ROOT: Node3D

@export var SKELETON_ROOT_ROTATION_TRACKINDEX: int = 1

# Use on mesh of character
# Make sure rig skeletal animationplayer uses physics callback or will not be moving enough
# Make sure root bone in rig is represented by a quaternion (potentially not an issue though)

var last_root_motion_position_accumulator: Vector3 = Vector3.ZERO
var last_root_motion_rotation_accumulator: Quaternion = Quaternion()

func transfer_skeleton_orientation_to_mesh():
	MESH.global_transform.basis *= SKELETON.global_transform.basis
	SKELETON.quaternion = Quaternion()  # reset to identity

func convert_blender_quat_to_godot(q: Quaternion) -> Quaternion: # Blender to godot
	var basis = Basis(q)
	var newBasis = Basis(basis.x, -basis.z, -basis.y)
	return newBasis.get_rotation_quaternion()
	
	#return Quaternion()

func _physics_process(_delta: float) -> void: 
	
	if !SKELETAL_ANIMATION_PLAYER: return
	if !SKELETON: return
	if !SCENE_ROOT: return

	var pos_accum = SKELETAL_ANIMATION_PLAYER.get_root_motion_position_accumulator()
	if pos_accum == Vector3.ZERO:
		last_root_motion_position_accumulator = Vector3.ZERO
	var delta_pos = pos_accum - last_root_motion_position_accumulator
	last_root_motion_position_accumulator = pos_accum
	
	var initial_skeleton_position = SKELETON.position
	SKELETON.position += delta_pos
	SCENE_ROOT.global_transform.origin += (SKELETON.global_transform.origin - initial_skeleton_position) - SCENE_ROOT.global_transform.origin 
	SKELETON.position = initial_skeleton_position
	

	


	var anim = SKELETAL_ANIMATION_PLAYER.get_animation(SKELETAL_ANIMATION_PLAYER.current_animation)
	var time = SKELETAL_ANIMATION_PLAYER.current_animation_position
	if anim: 
		var rot_quat = anim.rotation_track_interpolate(1,time)

		#print(convert_blender_quat_to_godot(rot_quat) )

		SKELETON.quaternion = convert_blender_quat_to_godot(rot_quat) # example extra rotation

		#print(rot_quat)


	
	
	#SKELETON.quaternion = last_root_motion_rotation_accumulator
	

	#
