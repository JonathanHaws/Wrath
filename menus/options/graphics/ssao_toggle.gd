extends CheckButton

func _ready() -> void:
	toggled.connect(_on_toggled)
	button_pressed = Config.load_setting("graphics", "ssao_enabled", true)

func _on_toggled(enabled: bool) -> void:
	var env := get_viewport().get_world_3d().environment
	if env: env.ssao_enabled = enabled
	Config.save_setting("graphics", "ssao_enabled", enabled)
