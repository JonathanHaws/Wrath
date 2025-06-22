extends Control
@export var profile_scene: PackedScene
@export var exclude_current_save: bool = false

func populate_menu_with_saves() -> void:	
	
	for child in get_children():
		if child.name == "Back":
			continue
		remove_child(child)
		child.queue_free()
	
	var saves = Save.get_save_files(exclude_current_save)
	for save in saves:
		var profile = profile_scene.instantiate()
		profile.format_profile(save)
		profile.pressed.connect(Save.load_game.bind(save["file_name"]))
		add_child(profile)
		move_child(profile, 0)  
		
func _ready() -> void:
	populate_menu_with_saves()
