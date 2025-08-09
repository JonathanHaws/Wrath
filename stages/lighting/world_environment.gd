extends WorldEnvironment

func _ready() -> void:
	environment.adjustment_enabled = true

	var brightness_default = environment.adjustment_brightness
	var contrast_default = environment.adjustment_contrast
	var saturation_default = environment.adjustment_saturation

	environment.adjustment_brightness = Config.load_setting("display", "brightness", brightness_default)
	environment.adjustment_contrast = Config.load_setting("display", "contrast", contrast_default)
	environment.adjustment_saturation = Config.load_setting("display", "saturation", saturation_default)
	
	environment.ssao_enabled = Config.load_setting("graphics", "ssao_enabled", true)
	environment.glow_enabled = Config.load_setting("graphics", "bloom_enabled", true)
