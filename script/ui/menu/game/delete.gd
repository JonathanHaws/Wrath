extends Control
@export var profile_scene: PackedScene
@export var exclude_current_save: bool = false

func delete_save(profile: String,) -> void:
	Save.delete_save(profile)
	populate_menu_with_saves()

func populate_menu_with_saves() -> void:	
	
	for node in get_tree().get_nodes_in_group("profile"):
		node.queue_free()
	
	var saves = Save.get_save_files(exclude_current_save)
	for save in saves:
		var profile = profile_scene.instantiate()
		profile.format_profile(save)
		profile.pressed.connect(delete_save.bind(save["file_name"]))
		add_child(profile)
		move_child(profile, 0)  
		
func _ready() -> void:
	populate_menu_with_saves()
