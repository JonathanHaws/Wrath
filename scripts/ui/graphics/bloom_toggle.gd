extends CheckButton

func _ready() -> void:
	toggled.connect(_on_toggled)

func _on_toggled(button_pressed: bool) -> void:
	var env := get_viewport().get_world_3d().environment
	if env:
		env.glow_enabled = button_pressed
