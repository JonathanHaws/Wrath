extends Control
@export var focus_target: Control

func _ready() -> void:
	if focus_target:
		focus_target.call_deferred("grab_focus")  # ensures focus actually works
