extends Node3D
@export var SKELETAL_ANIMATION_PLAYER: AnimationPlayer 
@export var SCENE_ROOT: Node3D
# make sure to apply all transformations to the rig in 3d software if not working
# Use on mesh of character
# Make sure mesh anim uses physics callback or will not be moving enough

func _physics_process(_delta: float) -> void: 
	
	if !SKELETAL_ANIMATION_PLAYER: return
	if !SCENE_ROOT: return
	
	var root_motion_position = SKELETAL_ANIMATION_PLAYER.get_root_motion_position()
	#print(root_motion_position)
	
	# Rotate to root motion to affect in orientation of mesh
	var transformed_root_motion = global_transform.basis * root_motion_position
	
	# Apply it to the scene root
	SCENE_ROOT.global_transform.origin += transformed_root_motion; 
