# Use on mesh of character
# Make sure rig skeletal animationplayer uses physics callback or will not be moving enough
# Make sure root bone in rig is represented by a quaternion (potentially not an issue though)

extends Node3D
@export var SKELETAL_ANIMATION_PLAYER: AnimationPlayer 
@export var SKELETON: Node3D
@export var MESH: Node3D
@export var BODY: Node3D
@export var ROOT_BONE_NAME: String = "root"
@export var DEFAULT_TRANSFORM_ANIMATION: String = "Idle" ## Somtimes root is not identity or zero. This animation at time specifies default transform 
var last_time: float = 0.0 ## When current playback time goes backward its known a new animation has started so can reset root motion
var default_root_position: Vector3 = Vector3.ZERO 
var default_root_rotation: Quaternion = Quaternion() 
var last_track_position: Vector3 = default_root_position 

func manual_move_and_slide(body: CharacterBody3D, motion: Vector3, max_bounces: int = 4) -> void:
	## Basically move and slide but independent and not affecting velocity in any way
	var remaining = motion
	for i in max_bounces:
		if remaining.length() == 0: break
		var collision = body.move_and_collide(remaining)
		if not collision: break
		remaining = remaining.slide(collision.get_normal())

func convert_blender_quat_to_godot(q: Quaternion) -> Quaternion: # Blender to godot
	return q *  default_root_rotation.inverse()

func transfer_skeleton_orientation_to_mesh():
	BODY.global_transform.basis = SKELETON.global_transform.basis
	MESH.quaternion = Quaternion() # reset to identity
	SKELETON.quaternion = Quaternion()  

func find_root_tracks(anim: Animation) -> Dictionary:
	var pos_idx: int = -1
	var rot_idx: int = -1
	for i: int in anim.get_track_count():
		var path: NodePath = anim.track_get_path(i)
		if !str(path).ends_with(ROOT_BONE_NAME): continue
		var type: int = anim.track_get_type(i)
		if type == Animation.TYPE_POSITION_3D: pos_idx = i
		elif type == Animation.TYPE_ROTATION_3D: rot_idx = i
	return {"position": pos_idx, "rotation": rot_idx}

func _ready() -> void:
	var anim = SKELETAL_ANIMATION_PLAYER.get_animation(DEFAULT_TRANSFORM_ANIMATION)
	if not anim: return
	var tracks: Dictionary = find_root_tracks(anim)
	
	if tracks["position"] != -1:
		default_root_position = anim.position_track_interpolate(tracks["position"], 0.0)
		last_track_position = default_root_position

	if tracks["rotation"] != -1:
		default_root_rotation = anim.rotation_track_interpolate(tracks["rotation"], 0.0)
	
func _physics_process(_delta: float) -> void: 
	if !SKELETAL_ANIMATION_PLAYER or !SKELETON or !BODY: return
	if not SKELETAL_ANIMATION_PLAYER.is_playing(): return

	var anim = SKELETAL_ANIMATION_PLAYER.get_animation(SKELETAL_ANIMATION_PLAYER.current_animation)
	var time = SKELETAL_ANIMATION_PLAYER.current_animation_position
	var tracks: Dictionary = find_root_tracks(anim)
	
	if time < last_time: last_track_position = default_root_position
	last_time = time

	if tracks["position"] != -1:
		var track_position = anim.position_track_interpolate(tracks["position"], min(time, anim.length))
		var track_position_delta = track_position - last_track_position
		last_track_position = track_position	
		

		var global_skeleton_position = SKELETON.get_parent().to_global(SKELETON.position + track_position_delta)
		var delta_position = (global_skeleton_position - SKELETON.position) - BODY.global_position	# delta
		
		manual_move_and_slide(BODY, delta_position)

		
	if tracks["rotation"] != -1:
		var rot_quat = anim.rotation_track_interpolate(tracks["rotation"], min(time, anim.length)) # Avoid out of bounds access
		SKELETON.quaternion = convert_blender_quat_to_godot(rot_quat) # example extra rotation
		#print(convert_blender_quat_to_godot(rot_quat) )
