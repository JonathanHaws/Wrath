extends Control
@export var focus_targets: Array[Control]

func _apply_focus() -> void:
	for target in focus_targets:
		if target and target.visible:
			target.call_deferred("grab_focus")
			return

func _ready() -> void:
	#add_to_group(focus_group)
	for target in focus_targets:
		if not target: continue
		target.visibility_changed.connect(_apply_focus)
	_apply_focus()

# Poll to ensure focus is always available for controller players
func _process(_delta: float) -> void: 
	if not is_visible_in_tree(): return
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	if not is_instance_valid(focus_owner):
		_apply_focus()	
