extends Control
@export var save_theme: Theme

func format_time(total_seconds: float) -> String:
	var total_seconds_int = int(total_seconds)
	var milliseconds = int(fmod(total_seconds, 1) * 10) 
	var time_parts = []
	if total_seconds_int >= 86400: time_parts.append(str(total_seconds_int / 86400.0))
	if total_seconds_int >= 3600: time_parts.append("%02d" % ((total_seconds_int % 86400) / 3600.0))
	if total_seconds_int >= 60: time_parts.append("%02d" % ((total_seconds_int % 3600) / 60.0))
	time_parts.append("%02d.%d" % [total_seconds_int % 60, milliseconds])
	return ":".join(time_parts)

func clear_saves() -> void:
	for child in get_children():
		if child.name == "Back":
			continue
		remove_child(child)
		child.queue_free()

func populate_menu_with_saves() -> void:	
	
	clear_saves()
	
	var saves = Save.get_save_files()
	for save in saves:
		var button = Button.new()
		button.theme = save_theme
		if "play_time" in save:
			button.text = save["file_name"].split(".")[0] + " " + format_time(save["play_time"])
		else:
			button.text = save["file_name"].split(".")[0]
		#button.mouse_entered.connect(_play_hover_sound)
		button.pressed.connect(Save.delete_save.bind(save["file_name"]))
		add_child(button)
		move_child(button, 0)  
		
func _ready() -> void:
	visibility_changed.connect(populate_menu_with_saves)
