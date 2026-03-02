extends Node
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

#region Audio
const BUSES = ["Master", "Music", "SFX"]
const DEFAULT = 100.0
func load_audio_settings() -> void:
	for bus_name in BUSES:
		var value = load_setting("audio", bus_name, DEFAULT)
		var bus_idx = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
		#endregion

#region Graphics

#region UI Scale
var BASE_UI_SCALE = 1.0
var UI_SCALE = 1
signal ui_scale_changed(new_scale: Vector2)
func set_ui_scale(value: float) -> void:
	for node in get_tree().get_nodes_in_group("ui_scalable"):
		node.scale = Vector2(value, value)
		#print('being changed')
		#print(get_parent().name)
	UI_SCALE = value
	emit_signal("ui_scale_changed", Vector2(value, value))
	#reduce_ui_scale_until_contained()

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

#endregion

#region Resolution
var BASE_RES 
func set_resolution(res_size: Vector2) -> void: 
	get_window().content_scale_size = res_size
	Config.save_setting("display", "resolution_width", res_size.x)
	Config.save_setting("display", "resolution_height", res_size.y)
	var diff = (res_size.x / BASE_RES.x + res_size.y / BASE_RES.y) * 0.5
	UI_SCALE = BASE_UI_SCALE * diff
	set_ui_scale(UI_SCALE)
func load_resolution() -> void:
	BASE_RES = Vector2( ## Force max resolution to be 1920*1080 memoery seems to run out for audio otherwise
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))
	var width = load_setting("display", "resolution_width", get_window().size.x)
	var height = load_setting("display", "resolution_height", get_window().size.y)
	set_resolution(Vector2i(min(width, 1920), min(height, 1080))) 
#endregion

#region Window
var _window_save_timer: Timer = null
var _window_save_time: float = 0.3
func get_window_mode() -> int: return DisplayServer.window_get_mode()
func set_window_mode(index: int) -> void:
	save_setting("display", "window_mode", index)
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)	
func save_window_position() -> void:
	save_setting("display", "window_x", get_window().position.x)
	save_setting("display", "window_y", get_window().position.y)
func save_window_size() -> void:
	save_setting("display", "window_width", get_window().size.x)
	save_setting("display", "window_height", get_window().size.y)
func load_window_position() -> void:
	var x = load_setting("display", "window_x", get_window().position.x)
	var y = load_setting("display", "window_y", get_window().position.y)
	get_window().position = Vector2(x, y)
func load_window_size() -> void:
	var w = load_setting("display", "window_width", get_window().size.x)
	var h = load_setting("display", "window_height", get_window().size.y)
	get_window().size = Vector2(w, h)	
func save_window_transform() -> void:
	save_window_position()
	save_window_size()
func load_window_transform() -> void:
	load_window_position()
	load_window_size()
func _on_window_size_changed() -> void:
	if not _window_save_timer:
		_window_save_timer = Timer.new()
		_window_save_timer.one_shot = true
		_window_save_timer.autostart = false
		_window_save_timer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_window_save_timer)
		_window_save_timer.timeout.connect(func() -> void:
			save_window_transform()
			_window_save_timer.queue_free()
			_window_save_timer = null
			#print('saving window position and scale')
		)
	_window_save_timer.start(_window_save_time) 
func load_graphics_settings() -> void:
	set_window_mode(load_setting("display", "window_mode", 1))
	load_window_transform()
	load_resolution()
#endregion

#endregion

func _ready() -> void:
	load_graphics_settings()
	load_audio_settings()
