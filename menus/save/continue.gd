extends Control

func _on_continue_pressed() -> void:
	var save_files = Save.get_save_files()
	if save_files.size() > 0:
		
		Save.load_save_data(save_files[0]["file_name"]) 
		Save.data["rests"] = (Save.data.get("rests", 0) + 1)
		Save.save_game()
		Save.load_game(save_files[0]["file_name"])

func _on_visibility_changed() -> void:
	var save_files = Save.get_save_files()
	if not save_files.size() > 0:
		if self.visible:
			self.visible = false
		return
	if not self.visible:
		self.visible = true
	
func _ready() -> void:
	_on_visibility_changed()
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))	
	connect("pressed", Callable(self, "_on_continue_pressed"))
