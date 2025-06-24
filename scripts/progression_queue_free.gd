extends Node
@export var anim_player: AnimationPlayer
@export var anim_name: String
@export var save_key: String

func _ready():
	if not Save.data.has(save_key): return
	if anim_player:
		anim_player.play(anim_name)
	else:
		queue_free()
