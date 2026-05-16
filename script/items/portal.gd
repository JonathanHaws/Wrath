extends Node3D
@export var animation_player: AnimationPlayer 
@export var unlocked_animation: String = "unlocked"
@export var save_keys: Array[String] = [
	"lust_defeated",
	"gluttony_defeated",
	"greed_defeated",
	"sloth_defeated",
	"wrath_defeated",
	"envy_defeated",
	#"pride_defeated",
	]

var unlocked: bool = false

func check_unlock() -> void:
	if unlocked: return
	for save_key in save_keys:
		if !Save.data.has(save_key): 
			#print('havent gotten ' + save_key + ' yet.')
			return
	animation_player.play(unlocked_animation)
	unlocked = true

func _ready() -> void:
	check_unlock()
	Save.save_data_updated.connect(check_unlock)
