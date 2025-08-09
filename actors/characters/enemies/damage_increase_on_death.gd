extends Node
@export var HITBOX: Node
@export var DAMAGE_INCREASE := 1.1
@export var DAMAGE_KEY := ""

var initial_health := 0

func _ready() -> void:
	initial_health = HITBOX.HEALTH

func _exit_tree() -> void:
	if DAMAGE_KEY != "" and initial_health > 0 and HITBOX.HEALTH <= 0:
		Save.data[DAMAGE_KEY] = int(Save.data.get(DAMAGE_KEY, 1) * DAMAGE_INCREASE)
		Save.save_game()
