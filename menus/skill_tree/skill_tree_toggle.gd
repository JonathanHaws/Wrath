extends Node
@export var skill_tree_ui: Control
var skill_tree_open := false

func _process(_delta):
	if Input.is_action_just_pressed("toggle_skill_tree"):
		#print('test')
		skill_tree_open = !skill_tree_open
		skill_tree_ui.visible = skill_tree_open

		if skill_tree_open:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
