extends Control
@export_file("*.tscn") var default_scene_file: String

func _on_continue_pressed() -> void:
	var save_files = Save.get_save_files()
	if save_files.size() > 0:
		Save.load_game(save_files[0]["file_name"])
		if default_scene_file != "":
			get_tree().change_scene_to_file(default_scene_file)

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
