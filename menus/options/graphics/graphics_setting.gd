extends Control
@export var setting_name := ""
func get_environment() -> Environment:
	var world := get_viewport().get_world_3d()
	if not world: return null
	return world.environment
func _ready() -> void:
	if toggle_button:
		toggle_button.toggled.connect(_on_toggled)
		_on_toggled(Config.load_setting("display", setting_name, toggle_button.button_pressed))
	if slider: 	
		slider.value_changed.connect(_on_value_changed)
		_on_value_changed(Config.load_setting("display", setting_name, slider.value))

@export_group("Toggle Button")
@export var toggle_button: CheckButton
@export var toggled_default: bool = true
func _on_toggled(enabled: bool) -> void:
	toggle_button.button_pressed = enabled
	Config.save_setting("display", setting_name, enabled)
	var env = get_environment(); if env: match setting_name:
		"bloom_enabled": env.glow_enabled = enabled
		"ssao_enabled": env.ssao_enabled = enabled

@export_group("Slider")
@export var slider: HSlider
@export var display_label: Label
func _on_value_changed(new_value: float) -> void:
	slider.value = new_value
	Config.save_setting("display", setting_name, new_value)
	if display_label: display_label.text = str(new_value)
	var env = get_environment(); if env: match setting_name:
		"brightness": env.adjustment_brightness = new_value
		"contrast": env.adjustment_contrast = new_value
		"saturation": env.adjustment_saturation = new_value
		"ssao_radius": env.ssao_radius = new_value
		"ssao_intensity": env.ssao_intensity = new_value
