extends Node3D
@export var SKELETAL_ANIMATION_PLAYER: AnimationPlayer 
@export var SCENE_ROOT: Node3D
# Use on mesh of character
# Make sure rig skeletal animationplayer uses physics callback or will not be moving enough
# Make sure root bone in rig is represented by a quaternion (potentially not an issue though)

func remap_quaternion_from_blender_to_godot(q: Quaternion) -> Quaternion: # Rortation needs to be converted for some reason
	return Quaternion(q.x, q.z, -q.y, q.w)

func _physics_process(_delta: float) -> void: 
	
	if !SKELETAL_ANIMATION_PLAYER: return
	if !SCENE_ROOT: return

	
	#var original_scene = SCENE_ROOT.global_transform # record original transform 
	##apply root motion rotation
	#SCENE_ROOT.set_quaternion((remap_quaternion_from_blender_to_godot(SKELETAL_ANIMATION_PLAYER.get_root_motion_rotation())))
	#
	#SCENE_ROOT.global_transform *= original_scene	
	
	#apply scene position 
	SCENE_ROOT.global_transform.origin += global_transform.basis * SKELETAL_ANIMATION_PLAYER.get_root_motion_position(); 
