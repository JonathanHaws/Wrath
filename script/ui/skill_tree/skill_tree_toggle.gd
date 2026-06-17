extends Node
## Disables skill tree if this camera is not active. Set it to empty if it should always be available
@export var player_camera_group: String = "player_camera" 
@export var open_anim: String = "open"
@export var close_anim: String = "close"
@export var ANIM: AnimationPlayer 
var skill_tree_open: bool = false

func get_camera_current() -> bool:
	var cam := get_tree().get_first_node_in_group(player_camera_group)
	return cam != null and cam.current

func play_config_animation(animation: String) -> void:
	if !Config: return
	Config.play_animation_by_group(animation)
	
func toggle_skill_tree() -> void:
	## Controller B to exit skill tree but dont dash
	await get_tree().physics_frame 
	await get_tree().physics_frame
	skill_tree_open = !skill_tree_open
	
	if not ANIM: return
	if skill_tree_open: 
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		ANIM.queue(open_anim)
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		ANIM.queue(close_anim)

func _process(_delta):
	
	if not get_camera_current() and skill_tree_open: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		skill_tree_open = false
		ANIM.queue(close_anim)


	if skill_tree_open and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if Input.is_action_just_pressed("menu_back") and skill_tree_open: toggle_skill_tree()
	
	if get_camera_current(): if Input.is_action_just_pressed("toggle_skill_tree"): toggle_skill_tree()
