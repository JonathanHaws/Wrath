# Use on mesh of character
# Make sure rig skeletal animationplayer uses physics callback or will not be moving enough
# Make sure root bone in rig is represented by a quaternion (potentially not an issue though)

extends Node3D
@export var SKELETAL_ANIMATION_PLAYER: AnimationPlayer 
@export var SKELETON: Node3D
@export var MESH: Node3D
@export var SCENE_ROOT: Node3D
@export var SKELETON_ROOT_POSITION_TRACK_INDEX: int = 0
@export var SKELETON_ROOT_ROTATION_TRACK_INDEX: int = 1
@export var SKELETON_ROOT_DEFAULT_POSITION: Vector3 = Vector3.ZERO ## Look in skeleton mesh animation player root rotation 
@export var SKELETON_ROOT_DEFAULT_ROTATION: Quaternion = Quaternion()  ## Look in skeleton mesh animation player root rotation 

var last_root_pos: Vector3 = SKELETON_ROOT_DEFAULT_POSITION  # declare at top
var last_time: float = 0.0 ## When animation current playback goes backward you can know new animation has played so can reset root motion

func convert_blender_quat_to_godot(q: Quaternion) -> Quaternion: # Blender to godot
	return q * SKELETON_ROOT_DEFAULT_ROTATION.inverse()

func transfer_skeleton_orientation_to_mesh():
	SCENE_ROOT.global_transform.basis = SKELETON.global_transform.basis
	MESH.quaternion = Quaternion()
	SKELETON.quaternion = Quaternion()  # reset to identity

func ready() -> void:
	last_root_pos = SKELETON_ROOT_DEFAULT_POSITION

func _physics_process(_delta: float) -> void: 
	
	if !SKELETAL_ANIMATION_PLAYER: return
	if !SKELETON: return
	if !SCENE_ROOT: return
	if not SKELETAL_ANIMATION_PLAYER.is_playing(): return
	if SKELETAL_ANIMATION_PLAYER.current_animation == "": return

	var anim = SKELETAL_ANIMATION_PLAYER.get_animation(SKELETAL_ANIMATION_PLAYER.current_animation)
	var time = SKELETAL_ANIMATION_PLAYER.current_animation_position

	if time < last_time:
		last_root_pos = SKELETON_ROOT_DEFAULT_POSITION
	last_time = time

	# POSITION 
	var pos_path = anim.track_get_path(SKELETON_ROOT_POSITION_TRACK_INDEX)
	if str(pos_path).ends_with("root") and anim.track_get_type(SKELETON_ROOT_ROTATION_TRACK_INDEX) == Animation.TYPE_ROTATION_3D:
		var root_pos = anim.position_track_interpolate(SKELETON_ROOT_POSITION_TRACK_INDEX, min(time, anim.length))
		var delta_root_pos = root_pos - last_root_pos
		last_root_pos = root_pos	
		
		var initial_skeleton_position = SKELETON.position
		SKELETON.position += delta_root_pos 
		SCENE_ROOT.global_transform.origin += (SKELETON.global_transform.origin - initial_skeleton_position) - SCENE_ROOT.global_transform.origin 
		SKELETON.position = initial_skeleton_position
		
	# ROTATION
	var rot_path = anim.track_get_path(SKELETON_ROOT_ROTATION_TRACK_INDEX)
	if str(rot_path).ends_with("root") and anim.track_get_type(SKELETON_ROOT_ROTATION_TRACK_INDEX) == Animation.TYPE_ROTATION_3D:
		var rot_quat = anim.rotation_track_interpolate(SKELETON_ROOT_ROTATION_TRACK_INDEX, min(time, anim.length)) # Avoid out of bounds access
		SKELETON.quaternion = convert_blender_quat_to_godot(rot_quat) # example extra rotation
		#print(convert_blender_quat_to_godot(rot_quat) )
