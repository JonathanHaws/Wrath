extends HSlider
@export var camera_group: String = "player_camera"
@export var camera_property_name: String = "MOUSE_SENSITIVITY"
@export var config_setting_name: String = "mouse_sensitivity"
@export var value_label: Label

func _ready() -> void:
	for node in get_tree().get_nodes_in_group(camera_group):
		value = node.get(camera_property_name)
		
	value = Config.load_setting("controls", config_setting_name, value)
		
	_on_value_changed(value)	
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value

	Config.save_setting("controls", config_setting_name, value)
	
	for node in get_tree().get_nodes_in_group(camera_group):
		node.set(camera_property_name, value)
		
	if value_label:
		var s = str("%.3f" % (value * 100))
		value_label.text = s.substr(0, 3)
