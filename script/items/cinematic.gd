extends Node ## Always try to have player camera as the first or oldest child in the scene tree 
@export var AREA: Area3D ## Area which if entered by a body apart of the player body group will trigger cutscene
@export var ANIMATION_PLAYER_GROUPS: Array[String] ## For globally calling other objects who need to play an animation for this cutscene too
@export var ANIMATION_NAMES: Array[String] ## Corresponding animations for the global objects
@export var ANIM: AnimationPlayer ## Animation player that will play the cinematic animation
@export var PLAYER_SPOT: Node3D ## Spot player will be teleported when the animation plays
@export var ANIM_NAME: String = "" ## Name of the cinematic animation to be played
@export var SAVE_KEY: String = "" ## Save if completed for one time cutscenes. If empty wont save
@export var SKIPPER_GROUP: String = "skipper" ## Skipper node enables skip function
@export var PLAYER_BODY_GROUP: String = "player_body" ## The type or group of the players body

func _on_body_entered(body: Node) -> void:
	if PLAYER_BODY_GROUP != "" and not body.is_in_group(PLAYER_BODY_GROUP): return
	_play_animations_in_other_nodes()		
	if ANIM and ANIM.has_animation(ANIM_NAME): ANIM.play(ANIM_NAME)

func _play_animations_in_other_nodes() -> void:
	#print('test ', get_path(), '' , ANIM_NAME)
	if not is_inside_tree(): return
	#print ('playing animations in other nodes')
	for i in range(ANIMATION_PLAYER_GROUPS.size()):
		if i >= ANIMATION_NAMES.size(): continue
		for node in get_tree().get_nodes_in_group(ANIMATION_PLAYER_GROUPS[i]):
			if node is AnimationPlayer and node.has_animation(ANIMATION_NAMES[i]):
				node.play(ANIMATION_NAMES[i])		

func _skip_cinematic() -> void:
	await get_tree().process_frame # Autoload doesnt start playing until after ready so wait until an animation is playing so seek works
	if not is_inside_tree(): return
	for skipper in get_tree().get_nodes_in_group(SKIPPER_GROUP):
		if "_skip" in skipper:
			skipper._skip()

func seamless_cam_trans(duration: float = 1.5, target_camera_group: String = "player_camera", save_completed: bool = false) -> void:
	var current_camera = get_viewport().get_camera_3d()
	var target_camera = get_tree().get_first_node_in_group(target_camera_group)
	
	# make new camera to avoid issues changing current or target properties
	# also if theres animations on them or code they might override transition
	var transition_camera := Camera3D.new() 
	get_tree().current_scene.add_child(transition_camera) 
	transition_camera.global_transform = current_camera.global_transform
	transition_camera.fov = current_camera.fov
	transition_camera.current = true
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(transition_camera, "global_transform", target_camera.global_transform, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(transition_camera, "fov", target_camera.fov, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		target_camera.current = true
		transition_camera.queue_free()
		if save_completed: _save_cinematic_completed()
		)
	
func _teleport_player_to_player_spot() -> void:
	if not PLAYER_SPOT: return
	var player = get_tree().get_nodes_in_group("player_body")[0]
	player.global_transform.origin = PLAYER_SPOT.global_transform.origin
	
	print(PLAYER_SPOT.global_transform.origin, player.global_transform.origin )
	player.global_transform = PLAYER_SPOT.global_transform
	player.global_transform = PLAYER_SPOT.global_transform
	player.MESH.transform = Transform3D.IDENTITY
	player.MESH_ANIM.playback_default_blend_time = 0

func _save_cinematic_completed() -> void:
	if SAVE_KEY == "": return
	Save.data[SAVE_KEY] = true
	Save.save_game()

func _ready() -> void:
	if AREA: 
		AREA.body_entered.connect(_on_body_entered)
	
	if Save.data.has(SAVE_KEY): # Cutscene is only supposed to play 1 time
		#print('cutscene already played')
		queue_free()
