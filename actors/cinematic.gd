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
var last_player_body : Node = null

@export_group("Seamless transition")
@export var CINEMATIC_CAMERA_GROUP: String = "cinematic_camera"
@export var TARGET_CAMERA_GROUP: String = "player_camera"

func _seamless_camera_transition(duration: float = 1.5) -> void: # todo add making it go in reverse player cam to cinematic
	var cinematic_list = get_tree().get_nodes_in_group(CINEMATIC_CAMERA_GROUP)
	var target_list = get_tree().get_nodes_in_group(TARGET_CAMERA_GROUP)
	if cinematic_list.size() == 0 or target_list.size() == 0: return
	var cinematic_camera = cinematic_list[0]
	var target_camera = target_list[0]
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(cinematic_camera, "global_transform", target_camera.global_transform, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cinematic_camera, "fov", target_camera.fov, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _skip_cinematic() -> void:
	await get_tree().process_frame # Autoload doesnt start playing until after ready so wait until an animation is playing so seek works
	if not is_inside_tree(): return

	for skipper in get_tree().get_nodes_in_group(SKIPPER_GROUP):
		if "_skip" in skipper:
			skipper._skip(false)

func _save_cinematic_completed() -> void:
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
