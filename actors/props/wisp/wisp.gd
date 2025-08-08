extends Node3D
@export var UPGRADE = 5.0
@export var HEALTH = true
@export var PLAYER_GROUP = "player"

func _on_body_entered(body: Node) -> void:
	
	if PLAYER_GROUP != "" and not body.is_in_group(PLAYER_GROUP): return
	if HEALTH:
		if Save.data.has("max_health"): Save.data["max_health"] += UPGRADE
	else:
		if Save.data.has("max_stamina"): Save.data["max_stamina"] += UPGRADE 
		
	Save.data[Save.get_unique_key(self,"_collected")] = true
	Save.save_game()
	
	$AnimationPlayer.play("delay_upgrade")

func _ready() -> void:
	
	if Save.data.has(Save.get_unique_key(self,"_collected")):
		queue_free()
	
