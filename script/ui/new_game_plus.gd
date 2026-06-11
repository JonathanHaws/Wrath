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

@export var HEALTH_MULTIPLIER_KEY: String = "enemy_health_multiplier"
@export var HEALTH_MULTIPLIERS: Array[float] = [
	1.0,  # NG
	1.5,  # NG+
	2.0,  # NG+2
	2.5,  # NG+3
	3.0,  # NG+4
	3.5,  # NG+5
	4.0,  # NG+6
]

@export var DAMAGE_MULTIPLIER_KEY: String = "enemy_damage_multiplier"
@export var DAMAGE_MULTIPLIERS: Array[float] = [
	1.0,  # NG
	1.5,  # NG+
	2.0,  # NG+2
	2.5,  # NG+3
	3.0,  # NG+4
	3.5,  # NG+5
	4.0,  # NG+6
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
	
	var ng: int = data["new_game_count"]
	data[HEALTH_MULTIPLIER_KEY] = HEALTH_MULTIPLIERS[mini(ng, HEALTH_MULTIPLIERS.size() - 1)]
	data[DAMAGE_MULTIPLIER_KEY] = DAMAGE_MULTIPLIERS[mini(ng, DAMAGE_MULTIPLIERS.size() - 1)]
	#print(HEALTH_MULTIPLIER_KEY, ": ", data[HEALTH_MULTIPLIER_KEY])
	#print(DAMAGE_MULTIPLIER_KEY, ": ", data[DAMAGE_MULTIPLIER_KEY])
	
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
	#print(Save.game_file_name)
	Save.load_game(Save.game_file_name)
