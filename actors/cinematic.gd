 # For cinematic cameras that need to become active. Use make_current() instead of animating current boolean property directly. 
# Because animation player can potentially overwrite and mess up some of the functionality of this script
extends Node
@export var SAVE_KEY: String = "" ## Save if completed for one time cutscenes 
@export var SKIPPER_GROUP: String = "skipper" ## Skipper node enables skip function
@export var ANIM: AnimationPlayer
@export var AREA: Area3D
@export var ANIM_NAME: String = ""
@export var PLAYER_BODY_GROUP = "player"
@export var PLAYER_SPOT: Node3D
@export var ANIMATION_PLAYER_GROUPS: Array[String]
@export var ANIMATION_NAMES: Array[String]
@export var TARGET_CAMERA_GROUP: String = "player_camera"
var last_player_body : Node = null

func _seamless_camera_transition(duration: float = 1.5, save_completed: bool = false) -> void: # todo add making it go in reverse player cam to cinematic
	var active_camera: Camera3D = get_viewport().get_camera_3d()
	var target_camera = get_tree().get_nodes_in_group(TARGET_CAMERA_GROUP)[0]
	if active_camera == target_camera: return
	if cinematic_completed(): return
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(active_camera, "global_transform", target_camera.global_transform, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(active_camera, "fov", target_camera.fov, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func(): 
		target_camera.make_current()
		if save_completed: save_cinematic_completed()
		)

func _skip_cinematic() -> void:
	await get_tree().process_frame # Autoload doesnt start playing until after ready so wait until an animation is playing so seek works
	if not is_inside_tree(): return
	
	save_cinematic_completed()
	get_tree().get_nodes_in_group(TARGET_CAMERA_GROUP)[0].make_current()

	for skipper in get_tree().get_nodes_in_group(SKIPPER_GROUP):
		if "_skip" in skipper:
			skipper._skip(false)

func cinematic_completed() -> bool:
	return SAVE_KEY != "" and Save.data.has(SAVE_KEY)

func save_cinematic_completed() -> void:
	if SAVE_KEY == "": return
	Save.data[SAVE_KEY] = true
	Save.save_game()

func _play_animations_in_other_nodes() -> void:
	if not is_inside_tree(): return
	
	#print ('playing animations in other nodes')
	for i in range(ANIMATION_PLAYER_GROUPS.size()):
		if i >= ANIMATION_NAMES.size(): continue
		
		for node in get_tree().get_nodes_in_group(ANIMATION_PLAYER_GROUPS[i]):
			if node is AnimationPlayer and node.has_animation(ANIMATION_NAMES[i]):
				node.play(ANIMATION_NAMES[i])
			
func _on_body_entered(body: Node) -> void:
	if PLAYER_BODY_GROUP != "" and not body.is_in_group(PLAYER_BODY_GROUP): return
	last_player_body = body
		
	_play_animations_in_other_nodes()
				
	if ANIM and ANIM.has_animation(ANIM_NAME): ANIM.play(ANIM_NAME)
	
func _teleport_player_to_player_spot() -> void:
	if not last_player_body or not PLAYER_SPOT: return
	last_player_body.global_transform.origin = PLAYER_SPOT.global_transform.origin
	last_player_body.global_transform = PLAYER_SPOT.global_transform
	last_player_body.global_transform = PLAYER_SPOT.global_transform
	last_player_body.MESH.transform = Transform3D.IDENTITY
	last_player_body.MESH_ANIM.playback_default_blend_time = 0
	
func _ready() -> void:
	if AREA: AREA.body_entered.connect(_on_body_entered)
	if SAVE_KEY != "" and Save.data.has(SAVE_KEY): _skip_cinematic()
