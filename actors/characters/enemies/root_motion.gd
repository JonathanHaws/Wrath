extends Node3D
@export var SKELETAL_ANIMATION_PLAYER: AnimationPlayer 
@export var SKELETON: Node3D
@export var MESH: Node3D
@export var SCENE_ROOT: Node3D
# Use on mesh of character
# Make sure rig skeletal animationplayer uses physics callback or will not be moving enough
# Make sure root bone in rig is represented by a quaternion (potentially not an issue though)

func transfer_skeleton_orientation_to_mesh():
	MESH.global_transform.basis *= SKELETON.global_transform.basis
	SKELETON.quaternion = Quaternion()  # reset to identity

func convert_coordinate_system_euler(q: Quaternion) -> Quaternion: # Blender to godot
	var euler := q.get_euler()
	var swapped_euler := Vector3(-euler.x, euler.z, euler.y)
	return Quaternion.from_euler(swapped_euler)

func _physics_process(_delta: float) -> void: 
	
	if !SKELETAL_ANIMATION_PLAYER: return
	if !SKELETON: return
	if !SCENE_ROOT: return

	var pos: Vector3 = SKELETAL_ANIMATION_PLAYER.get_root_motion_position()

	var initial_skeleton_position = SKELETON.position
	SKELETON.position += pos
	SCENE_ROOT.global_transform.origin += (SKELETON.global_transform.origin - initial_skeleton_position) - SCENE_ROOT.global_transform.origin 
	SKELETON.position = initial_skeleton_position
	#
	var rot: Quaternion = convert_coordinate_system_euler(SKELETAL_ANIMATION_PLAYER.get_root_motion_rotation())
	SKELETON.quaternion *= rot
	
	#print(pos, ros)
	#
