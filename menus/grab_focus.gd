extends Node
@export var focus_targets: Array[Control]

func _apply_focus() -> void:
	for target in focus_targets:
		if target and target.visible:
			target.call_deferred("grab_focus")
			return

func _ready() -> void:
	for target in focus_targets:
		if not target: continue
		target.visibility_changed.connect(_apply_focus)
	_apply_focus()
