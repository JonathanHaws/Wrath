extends Button
@export var SAVE_SUFFIXES: Array[String] = ["_skill"]
@export var SAVE_KEYS: Array[String] = ["max_health", "max_stamina", "damage", "auto_heal_rate", "auto_heal_delay", "max_shooting_energy", "shoot_damage"]
@export var GAME_COMPLETE_KEYS: Array[String] = [
	"lust_defeated",
	"gluttony_defeated",
	"greed_defeated",
	"sloth_defeated",
	"wrath_defeated",
	"envy_defeated",
]

func _ready() -> void:
	pressed.connect(_on_pressed)
	if Save.has_signal("save_data_updated"): Save.save_data_updated.connect(_on_save_data_updated)
	_on_save_data_updated()

func _on_save_data_updated() -> void:
	visible = true
	var count: int = Save.data.get("new_game_count", 0)
	text = "START NEW GAME +" + str(count + 1)
	if not is_game_complete():
		visible = false

func is_game_complete() -> bool:
	for key in GAME_COMPLETE_KEYS:
		if not Save.data.get(key, false):
			return false
	return true

func _on_pressed() -> void:
	if not Save.data.has("new_game_count"): Save.data["new_game_count"] = 0
	var data: Dictionary = {} # Data to carry over
	data["new_game_count"] = Save.data["new_game_count"] + 1
	
	for key in Save.data.keys():
		for suffix in SAVE_SUFFIXES:
			if str(key).ends_with(suffix):
				data[key] = Save.data[key]
				break

	for key in SAVE_KEYS:
		if Save.data.has(key):
			data[key] = Save.data[key]

	Save.data = data
	Save.save_game()
	print(Save.game_file_name)
	Save.load_game(Save.game_file_name)
