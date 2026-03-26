extends HSlider

func _ready() -> void:
	drag_ended.connect(_on_scale_changed)

func _on_scale_changed(scale_value_changed: bool) -> void:
	if not scale_value_changed: return 
	Config.set_ui_scale(value)
