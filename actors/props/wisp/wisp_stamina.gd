extends Node3D
@export var UPGRADE = 4.0
@export var PLAYER_GROUP = "player"
@export var ANIM: AnimationPlayer
@export var ANIM_NAME: String = "delay_upgrade"
@export var TRIGGER_AREA: Area3D  ## The area that triggers the upgrade

func _on_body_entered(body: Node) -> void:
	
	if PLAYER_GROUP != "" and not body.is_in_group(PLAYER_GROUP): return	
	if Save.data.has("max_stamina"): Save.data["max_stamina"] += UPGRADE 	
	Save.data[Save.get_unique_key(self,"_collected")] = true
	Save.save_game()	
	ANIM.play(ANIM_NAME)

func _ready() -> void:
	
	if Save.data.has(Save.get_unique_key(self,"_collected")): queue_free()
	TRIGGER_AREA.connect("body_entered", Callable(self, "_on_body_entered"))
