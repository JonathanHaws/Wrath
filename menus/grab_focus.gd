extends Node
@export var focus_target: Control

func _on_visibility_changed():
	if focus_target and focus_target.visible:
		focus_target.call_deferred("grab_focus")

func _ready() -> void:
	if focus_target:
		focus_target.visibility_changed.connect(_on_visibility_changed)
		if focus_target.visible: _on_visibility_changed()
