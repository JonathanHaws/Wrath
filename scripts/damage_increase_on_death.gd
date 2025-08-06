extends Node
@export var HITBOX: Node
@export var DAMAGE_INCREASE := 1.1
@export var DAMAGE_KEY := ""

func _exit_tree() -> void:
	if DAMAGE_KEY != "" and HITBOX.HEALTH <= 0:
		Save.data[DAMAGE_KEY] = int(Save.data.get(DAMAGE_KEY, 1) * DAMAGE_INCREASE)
