extends Node
@export var DAMAGE_INCREASE := 1.1
@export var DAMAGE_KEY := ""

func increase_player_damage() -> void:
	Save.data[DAMAGE_KEY] = int(Save.data.get(DAMAGE_KEY, 1) * DAMAGE_INCREASE)
	Save.save_game()
