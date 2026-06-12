extends Node
@export var TARGETS: Array[CanvasItem]
func _ready() -> void:
	Config.hide_ui_changed.connect(_on_hide_ui_changed)
	_on_hide_ui_changed(Config.HIDE_UI)

func _on_hide_ui_changed(hidden: bool) -> void:
	for target in TARGETS:
		if target:
			target.visible = !hidden
