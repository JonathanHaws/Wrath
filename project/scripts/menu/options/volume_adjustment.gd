extends HSlider

@export var bus_name: String
@export var default_value: float = 100.0

func _ready() -> void:
	
	var config = ConfigFile.new() # Load setting
	var err = config.load("user://settings.cfg")
	if err == OK: default_value = config.get_value("audio", bus_name, 100)
	
	_on_value_changed(default_value)
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
		
	var config = ConfigFile.new() # save setting
	config.load("user://settings.cfg") 
	config.set_value("audio", bus_name, value)
	config.save("user://settings.cfg")

		
