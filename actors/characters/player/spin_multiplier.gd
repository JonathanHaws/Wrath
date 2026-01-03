extends Node
@export var SPIN_DAMAGE_MULTIPLIER = 1.5 
@export var ATTACK_AREA: Area3D

func increase_damage_each_spin():
	if ATTACK_AREA: 
		ATTACK_AREA.damage_multiplier *= SPIN_DAMAGE_MULTIPLIER
		#print(ATTACK_AREA.damage_multiplier, ATTACK_AREA.damage)

func load_spin_damage()-> void:
	SPIN_DAMAGE_MULTIPLIER   = Save.data.get("spin_multiplier", SPIN_DAMAGE_MULTIPLIER)

func reset_damage():
	if ATTACK_AREA: ATTACK_AREA.damage_multiplier = 1

func _ready() -> void:
	load_spin_damage()
	Save.connect("save_data_updated", load_spin_damage)
