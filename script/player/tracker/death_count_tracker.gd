extends Node
@export var key: String
@export var HITSHAPE: Node

func _ready(): 
	if not Save.data.has(key): Save.data[key] = 0

func increase(): 
	Save.data[key] += 1
	
	if HITSHAPE and "MAX_HEALTH" in HITSHAPE and "HEALTH" in HITSHAPE:
		HITSHAPE.HEALTH = HITSHAPE.MAX_HEALTH
	
	if Save.data.has("respawn_data"):Save.data["respawn_data"].clear()
	
	Save.save_game()
	
