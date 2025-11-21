extends Node3D
@export var PLAYER_GROUP = "player"
@export var ANIM: AnimationPlayer
@export var ANIM_NAME: String = "delay_upgrade"
@export var TRIGGER_AREA: Area3D  ## The area that triggers the upgrade

func _on_body_entered(body: Node) -> void:
	
	if PLAYER_GROUP != "" and not body.is_in_group(PLAYER_GROUP): return	
	Save.data[Save.get_unique_key(self,"_collected")] = true
	
	if not Save.data.has("wisp"):
		Save.data["wisp"] = 0
	Save.data["wisp"] += 1
	
	Save.save_game()	
	ANIM.play(ANIM_NAME)

func _ready() -> void:
	
	if Save.data.has(Save.get_unique_key(self,"_collected")): queue_free()
	TRIGGER_AREA.connect("body_entered", Callable(self, "_on_body_entered"))
