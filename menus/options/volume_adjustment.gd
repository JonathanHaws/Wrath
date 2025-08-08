extends HSlider
@export var bus_name: String

func _ready() -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	_on_value_changed(db_to_linear(AudioServer.get_bus_volume_db(bus_idx)) * 100)
	connect("value_changed", _on_value_changed)

func _on_value_changed(new_value: float) -> void:
	value = new_value
	
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

	if Config: Config.save_setting("audio", bus_name, new_value)
		
