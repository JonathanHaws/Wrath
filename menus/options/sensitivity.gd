extends HSlider

@export var setting_name: String = "sensitivity"
@export var default_value: float = 0.003

func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		default_value = config.get_value("input", setting_name, default_value)

	_on_value_changed(default_value)
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value

	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("input", setting_name, value)
	config.save("user://settings.cfg")
	
	for node in get_tree().get_nodes_in_group("MOUSE_SENSITIVITY"):
		node.MOUSE_SENSITIVITY = value
