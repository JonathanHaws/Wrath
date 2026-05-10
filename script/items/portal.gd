extends Node3D

@export var animation_player: AnimationPlayer 
@export var unlocked_animation: String = "unlocked"
@export var save_keys: Array[String] = [
	"lust_defeated",
	"gluttony_defeated",
	"greed_defeated",
	"sloth_defeated",
	"wrath_defeated",
]

func check_unlock() -> void:
	for save_key in save_keys:
		if !Save.data.has(save_key): 
			print('havent beaten ' + save_key + ' yet.')
			return
	animation_player.play(unlocked_animation)

func _ready() -> void:
	check_unlock()

func _process(_delta: float) -> void:
	pass
