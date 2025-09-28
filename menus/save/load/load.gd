extends Control
@export_file("*.tscn") var default_scene_file: String
@export var profile_scene: PackedScene
@export var exclude_current_save: bool = false

func _on_profile_pressed(save_file: String) -> void:
	
	# If player leaves the game mid fight far away from the checkpoint this forces them to rest.
	# Contuing save file on a brand new day with mysteriously little health could be jarring. 
	# Unless potentially the position of the player is saved aswell. 
	# Which it is not currently. You always spawn at the last checkpoint you banked
	# So this just force rests before starting the session
	
	Save.load_save_data(save_file) 
	Save.data["rests"] = (Save.data.get("rests", 0) + 1)
	Save.save_game()
	Save.load_game(save_file)

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
		profile.pressed.connect(_on_profile_pressed.bind(save["file_name"]))
		add_child(profile)
		move_child(profile, 0)  
		
func _ready() -> void:
	populate_menu_with_saves()
