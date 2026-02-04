extends Node
@export var skill_tree_ui: Control
@export var toggle_disabled: bool = false
var skill_tree_open: bool = false

@export var PLAYER_GROUP = "player"
var original_attack_state: bool = false

func _process(_delta):
	
	#print(toggle_disabled)
	
	if Input.is_action_just_pressed("toggle_skill_tree") and !toggle_disabled:
		#print('test')
		skill_tree_open = !skill_tree_open
		skill_tree_ui.visible = skill_tree_open

		if skill_tree_open:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if Controls: Controls.play_input_anim("skill_tree_disable")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			if Controls: Controls.play_input_anim("skill_tree_enable")
