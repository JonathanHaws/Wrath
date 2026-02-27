extends Node
const BUSES = ["Master", "Music", "SFX"]
const DEFAULT = 100.0
var BASE_UI_SCALE = 1.0
var UI_SCALE = 1
var BASE_RES 

signal ui_scale_changed(new_scale: Vector2)
func set_ui_scale(value: float) -> void:
	for node in get_tree().get_nodes_in_group("ui_scalable"):
		node.scale = Vector2(value, value)
		#print('being changed')
		#print(get_parent().name)
	UI_SCALE = value
	emit_signal("ui_scale_changed", Vector2(value, value))
	
	#reduce_ui_scale_until_contained()

func load_graphics_settings(config: ConfigFile) -> void:
	BASE_RES = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
		)
	var width = config.get_value("display", "resolution_width", get_window().size.x)
	var height = config.get_value("display", "resolution_height", get_window().size.y)
	change_resolution(Vector2i(min(width, 1920), min(height, 1080))) ## above 1920 seems to break audio so set as default

func load_audio_settings(config: ConfigFile) -> void:
	for bus_name in BUSES:
		var value = config.get_value("audio", bus_name, DEFAULT)
		var bus_idx = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))


func change_resolution(res_size: Vector2) -> void:
	
	get_window().content_scale_size = res_size
	Config.save_setting("display", "resolution_width", res_size.x)
	Config.save_setting("display", "resolution_height", res_size.y)
	var diff = (res_size.x / BASE_RES.x + res_size.y / BASE_RES.y) * 0.5
	UI_SCALE = BASE_UI_SCALE * diff
	set_ui_scale(UI_SCALE)

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
	load_graphics_settings(config)
	load_audio_settings(config)

#func reduce_ui_scale_until_contained() -> void:
	#var win_size = get_window().content_scale_size
	#while true:
		#var rect = Rect2()
		#for node in get_tree().get_nodes_in_group("ui_scalable"):
			#if node is Control:
				#rect = rect.merge(node.get_global_rect())
		#if rect.end.x <= win_size.x and rect.end.y <= win_size.y: break
		#Config.UI_SCALE -= 0.05
		#for node in get_tree().get_nodes_in_group("ui_scalable"):
			#node.scale = Vector2(Config.UI_SCALE, Config.UI_SCALE)


	
