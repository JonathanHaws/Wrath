extends HSlider
@export var setting_name: String = "brightness"
@export var display_label: Label

func _ready() -> void:
	var env := get_viewport().get_world_3d().environment
	var default_value = 1.0
	if env:
		match setting_name:
			"brightness": default_value = env.adjustment_brightness
			"contrast": default_value = env.adjustment_contrast
			"saturation": default_value = env.adjustment_saturation
	_on_value_changed(Config.load_setting("display", setting_name, default_value))
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value
	if display_label:
		display_label.text = str(value)
	var env := get_viewport().get_world_3d().environment
	if env:
		match setting_name:
			"brightness": env.adjustment_brightness = value
			"contrast": env.adjustment_contrast = value
			"saturation": env.adjustment_saturation = value

	Config.save_setting("display", setting_name, value)
