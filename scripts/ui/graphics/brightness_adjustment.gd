extends HSlider
@export var default_value: float = 1.4

func _ready() -> void:
	_on_value_changed(Config.load_setting("display", "brightness", 1.4))
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value
	var env := get_viewport().get_world_3d().environment
	if env: env.adjustment_brightness = value

	Config.save_setting("display", "brightness", value)
