extends WorldEnvironment

func _ready() -> void:
	var brightness = Config.load_setting("display", "brightness", 1.0) 
	environment.adjustment_enabled = true
	environment.adjustment_brightness = brightness
	
	environment.ssao_enabled = Config.load_setting("graphics", "ssao_enabled", true)
	environment.glow_enabled = Config.load_setting("graphics", "bloom_enabled", true)
