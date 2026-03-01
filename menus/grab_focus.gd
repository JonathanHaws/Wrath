extends Node
@export var focus_targets: Array[Control]
#@export var focus_group: String = "focus_nodes" 	## Make it so when exiting from tree call apply focus on other grab focus nodes

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

#func _exit_tree() -> void:
	### Make it so when exiting from tree call apply focus on other grab focus nodes
	##var focus_owner: Control = get_viewport().gui_get_focus_owner()
	##if focus_owner == null:
		##return
	#
	#for node in get_tree().get_nodes_in_group(focus_group):
		#if node != self and node.has_method("_apply_focus"):
			#print('test')
			#node.call_deferred("_apply_focus")
