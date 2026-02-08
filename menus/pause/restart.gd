extends Button

func _ready() -> void:
	connect("pressed", _on_game_restart_pressed)

func _on_game_restart_pressed() -> void:
	if Save.data.has("checkpoint_scene_path"):
		if not Save.data.has("rests"): Save.data["rests"] = 1
		else: Save.data["rests"] += 1
		get_tree().change_scene_to_file(Save.data["checkpoint_scene_path"])
