extends Node
@export var DAMAGE_CURVE: Curve
@export var DAMAGE_MAX : float = 250.0
@export var DAMAGE_INCREASE := 0.02 ## 1 is added so its realy 1.02
# 35 enemies to double damagewolfram alpha claculation to help 1.02 ^ n = 2

@export var DAMAGE_KEY := ""

func increase_player_damage() -> void:
	
	var normalized_damage = clamp(Save.data.get(DAMAGE_KEY, 1) / DAMAGE_MAX, 0.0, 1.0)
	var dampened_damage_increase = 1 + (DAMAGE_INCREASE * DAMAGE_CURVE.sample_baked(normalized_damage))
	#print(dampened_damage_increase)
	
	Save.data[DAMAGE_KEY] = Save.data.get(DAMAGE_KEY, 1) * dampened_damage_increase
	Save.save_game()
