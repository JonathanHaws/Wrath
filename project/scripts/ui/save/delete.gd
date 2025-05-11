extends Control
@export var profile_scene: PackedScene

func delete_save(profile: String,) -> void:
	Save.delete_save(profile)
	populate_menu_with_saves()

func populate_menu_with_saves() -> void:	
	
	for child in get_children():
		if child.name == "Back":
			continue
		remove_child(child)
		child.queue_free()
	
	var saves = Save.get_save_files()
	for save in saves:
		var profile = profile_scene.instantiate()
		profile.format_profile(save)
		profile.pressed.connect(delete_save.bind(save["file_name"]))
		add_child(profile)
		move_child(profile, 0)  
		
func _ready() -> void:
	visibility_changed.connect(populate_menu_with_saves)
