extends Node3D
@export var UPGRADE = 5.0
@export var PLAYER_GROUP = "player"
@export var ANIM: AnimationPlayer
@export var ANIM_NAME: String = "delay_upgrade"

@export var TRIGGER_AREA: Area3D  ## The area that triggers the upgrade
@export var HURT_SHAPE: Node  ## AKA heal shape... set damage to -Upgrade to heal player upgrade amount

func _on_body_entered(body: Node) -> void:
	
	if PLAYER_GROUP != "" and not body.is_in_group(PLAYER_GROUP): return
	if Save.data.has("max_health"): Save.data["max_health"] += UPGRADE 
	Save.data[Save.get_unique_key(self,"_collected")] = true
	Save.save_game()
	ANIM.play(ANIM_NAME)

func _ready() -> void:
	
	if HURT_SHAPE: HURT_SHAPE.damage = -UPGRADE
	
	if Save.data.has(Save.get_unique_key(self,"_collected")): queue_free()
	TRIGGER_AREA.connect("body_entered", Callable(self, "_on_body_entered"))
