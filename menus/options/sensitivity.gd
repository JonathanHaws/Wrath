extends HSlider
@export var setting_name: String = "sensitivity"
@export var value_label: Label

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("MOUSE_SENSITIVITY"):
		value = node.MOUSE_SENSITIVITY
		
	_on_value_changed(value)	
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value

	Config.save_setting("controls", "sensitivity", value)
	
	for node in get_tree().get_nodes_in_group("MOUSE_SENSITIVITY"):
		node.MOUSE_SENSITIVITY = value
		
	if value_label:
		var s = str("%.3f" % (value * 100))
		value_label.text = s.substr(0, 3)
