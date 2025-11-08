extends Button
@export_file("*.tscn") var default_scene_file: String
@export var name_input: LineEdit
@export var error_label: Label
@export var max_saves: int = 5

@export var anim: AnimationPlayer ## Trigger an animation when pressed
@export var anim_name: String = "begin" ## String name of the animation to trigger

func generate_timestamped_filename() -> String:
	var datetime = Time.get_datetime_dict_from_system(false)
	var file_name = str(datetime.year) + "_"
	file_name += str(datetime.month).pad_zeros(2) + "_"
	file_name += str(datetime.day).pad_zeros(2) + "_"
	file_name += str(datetime.hour).pad_zeros(2) + "_"
	file_name += str(datetime.minute).pad_zeros(2) + "_"
	file_name += str(datetime.second).pad_zeros(2) + ".json"
	return file_name

func _on_game_new_pressed() -> void:
	
	var save_files = Save.get_save_files()
	if save_files and save_files.size() >= max_saves:
		if error_label: error_label.text = "MAXIMUM SAVE FILES IN USE."
		return
	
	for save in save_files:
		if name_input.text + ".json" == save["file_name"]:
			if error_label: error_label.text = "PICK A UNIQUE NAME."
			return
	
	if anim and anim_name != "": anim.play(anim_name)

func _begin() -> void:
	if not name_input: return 
		
	Save.load_game(name_input.text + ".json")
	if default_scene_file != "":
		get_tree().change_scene_to_file(default_scene_file)

func _ready() -> void:
	connect("pressed", _on_game_new_pressed)
