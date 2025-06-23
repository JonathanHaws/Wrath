extends HSlider
@export var default_value: float = 1.4

func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK: default_value = config.get_value("display", "brightness", 100)

	_on_value_changed(default_value)
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value
	var env := get_viewport().get_world_3d().environment
	if env: env.adjustment_brightness = value

	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("display", "brightness", value)
	config.save("user://settings.cfg")
