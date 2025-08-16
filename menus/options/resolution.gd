extends OptionButton

var resolutions = {
	"3840x2160": Vector2i(3840,2160),  # 4K
	"2560x1440": Vector2i(2560,1440),  # QHD
	"1920x1080": Vector2i(1920,1080),  # FHD
	"1600x900": Vector2i(1600,900),
	"1440x900": Vector2i(1440,900),
	"1366x768": Vector2i(1366,768),
	"1280x800": Vector2i(1280,800),
	"1280x720": Vector2i(1280,720),
	"1024x768": Vector2i(1024,768),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600),
	"800x480": Vector2i(800,480),
	"640x480": Vector2i(640,480),
	"480x320": Vector2i(480,320),
	"320x240": Vector2i(320,240),
	"240x160": Vector2i(240,160),
	"160x120": Vector2i(160,120),
	"128x96": Vector2i(128,96),
	"64x48": Vector2i(64,48),
}

func _ready() -> void:
	for res_key in resolutions.keys():
		add_item(res_key)
	
	item_selected.connect(_apply_resolution)
	
	var current = get_viewport_rect().size
	var closest_res := ""
	var min_diff := INF
	for res_name in resolutions.keys():
		var res_size = resolutions[res_name]
		var diff = abs(res_size.x - current.x) + abs(res_size.y - current.y)
		if diff < min_diff:
			min_diff = diff
			closest_res = res_name
	
	for i in range(item_count):
		if get_item_text(i) == closest_res:
			select(i)
			break

func _apply_resolution(index: int) -> void:
	var key := get_item_text(index)
	if resolutions.has(key):
		var res_size = resolutions[key]  
		var window = get_tree().get_root().get_window()
		window.content_scale_size = res_size
		Config.save_setting("display", "resolution_width", res_size.x)
		Config.save_setting("display", "resolution_height", res_size.y)
