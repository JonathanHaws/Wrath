extends WorldEnvironment

func _ready() -> void:
	var brightness = Config.load_setting("display", "brightness", 1.0) 
	environment.adjustment_enabled = true
	environment.adjustment_brightness = brightness
