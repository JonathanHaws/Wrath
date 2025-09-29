extends Node
@export var DAMAGE_INCREASE := 1.02 
# 35 enemies to double damagewolfram alpha claculation to help 1.02 ^ n = 2

@export var DAMAGE_KEY := ""

func increase_player_damage() -> void:
	Save.data[DAMAGE_KEY] = int(Save.data.get(DAMAGE_KEY, 1) * DAMAGE_INCREASE)
	Save.save_game()
