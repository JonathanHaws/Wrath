extends Node
@export var skill_tree_ui: Control
@export var toggle_disabled: bool = false
@export var PLAYER_GROUP = "player"
var skill_tree_open: bool = false

func toggle_skill_tree() -> void:
	## Controller B to exit skill tree but dont dash
	await get_tree().physics_frame 
	await get_tree().physics_frame
	
	skill_tree_open = !skill_tree_open
	skill_tree_ui.visible = skill_tree_open

	if skill_tree_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if Controls: Controls.play_input_anim("skill_tree_disable")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if Controls: Controls.play_input_anim("skill_tree_enable")

func _process(_delta):
	
	if Input.is_action_just_pressed("menu_back") and !toggle_disabled and skill_tree_open:
		toggle_skill_tree()
	
	if Input.is_action_just_pressed("toggle_skill_tree") and !toggle_disabled:
		toggle_skill_tree()
