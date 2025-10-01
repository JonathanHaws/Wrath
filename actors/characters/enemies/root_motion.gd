extends Node3D

@export var SKELETON: Node3D
@export var SKELETAL_ANIMATION_PLAYER: AnimationPlayer 
@export var SCENE_ROOT: Node3D
# Use on mesh of character
# Make sure rig skeletal animationplayer uses physics callback or will not be moving enough
# Make sure root bone in rig is represented by a quaternion (potentially not an issue though)

var prev_root_pos := Vector3.ZERO
var prev_root_rot := Quaternion.IDENTITY

func convert_coordinate_system(q: Quaternion) -> Quaternion: # Blender to godot
	var euler := q.get_euler()
	var swapped_euler := Vector3(-euler.x, euler.z, euler.y)
	return Quaternion.from_euler(swapped_euler)

func _physics_process(_delta: float) -> void: 
	
	if !SKELETAL_ANIMATION_PLAYER: return
	if !SKELETON: return
	if !SCENE_ROOT: return

	var pos: Vector3 = SKELETAL_ANIMATION_PLAYER.get_root_motion_position()
	SKELETON.position += pos 
	SCENE_ROOT.global_transform.origin += SKELETON.global_transform.origin - SCENE_ROOT.global_transform.origin
	SKELETON.position = Vector3.ZERO
	
	var rot: Quaternion = convert_coordinate_system(SKELETAL_ANIMATION_PLAYER.get_root_motion_rotation(),)
	SKELETON.quaternion *= rot
	#SCENE_ROOT.global_transform.basis *= (SKELETON.global_transform.basis * SCENE_ROOT.global_transform.basis.inverse())
	
	#SKELETON.transform = Transform3D.IDENTITY
