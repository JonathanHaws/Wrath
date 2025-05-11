extends Button

@export var name_input: LineEdit

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
	if name_input:
		Save.load_game(name_input.text + ".json")

func _ready() -> void:
	connect("pressed", _on_game_new_pressed)
