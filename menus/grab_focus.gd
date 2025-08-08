extends Node
@export var focus_node: Control

func _on_focus_node_visibility_changed() -> void:
	if focus_node.visible:
		focus_node.grab_focus()

func _ready() -> void:
	if focus_node:
		focus_node.connect("visibility_changed", Callable(self, "_on_focus_node_visibility_changed"))
		_on_focus_node_visibility_changed()  
