extends Node
@export var PLUNGE_DAMAGE_MULTIPLIER = .3 ## 30 percent more damage each second when falling
@export var PLAYER: Node ## Node with "falling" property which should return the amount of time theyve been in the air  
@export var ATTACK_AREA: Area3D

func increase_damage_plunge():
	if ATTACK_AREA: 
		#print('falling amount: ', falling)
		ATTACK_AREA.damage_multiplier = 1.0 + (PLAYER.falling * PLUNGE_DAMAGE_MULTIPLIER)

func reset_damage():
	if ATTACK_AREA: ATTACK_AREA.damage_multiplier = 1

func load_plunge_damage()-> void:
	PLUNGE_DAMAGE_MULTIPLIER   = Save.data.get("plunge_multiplier", PLUNGE_DAMAGE_MULTIPLIER)

func _ready() -> void:
	load_plunge_damage()
	Save.connect("save_data_updated", load_plunge_damage)
