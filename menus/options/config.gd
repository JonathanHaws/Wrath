extends Node
const BUSES = ["Master", "Music", "SFX"]
const DEFAULT = 100.0

func load_setting(section: String, key: String, default_value: Variant) -> Variant:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		return config.get_value(section, key, default_value)
	return default_value
	
func save_setting(section: String, key: String, value: Variant) -> void:
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value(section, key, value)
	config.save("user://settings.cfg")	

func _ready() -> void:
	var config = ConfigFile.new()
	config.load("user://settings.cfg")

	for bus_name in BUSES:
		var value = config.get_value("audio", bus_name, DEFAULT)
		var bus_idx = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
		
	var width = config.get_value("display", "resolution_width", get_window().size.x)
	var height = config.get_value("display", "resolution_height", get_window().size.y)
	get_window().content_scale_size = Vector2i(width, height)
