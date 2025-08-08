extends HSlider
@export var bus_name: String
@export var default_value: float = 100.0

func _ready() -> void:
	if Config: Config.load_setting("audio", bus_name, default_value)
	_on_value_changed(default_value)
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value
	
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

	if Config: Config.save_setting("audio", bus_name, default_value)
		
