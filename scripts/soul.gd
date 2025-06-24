extends Node3D
@export var COLLECTION_SOUNDS: Array[AudioStream] = []
@export var UPGRADE = 5.0
@export var HEALTH = true
@export var PLAYER_GROUP = "player"
var REAPER: Node

func _on_body_entered(body: Node) -> void:
	if PLAYER_GROUP != "" and not body.is_in_group(PLAYER_GROUP): return
	REAPER = body
	$AnimationPlayer.play("delay_upgrade")
	Audio.play_2d_sound(COLLECTION_SOUNDS[randi() % COLLECTION_SOUNDS.size()], 0.9, 1.1)

func _upgrade() -> void:
	if HEALTH:
		if not Save.data.has("max_health"):	Save.data["max_health"] = REAPER.MAX_HEALTH
		Save.data["max_health"] += UPGRADE
		REAPER.MAX_HEALTH = Save.data["max_health"]
		REAPER.HEALTH += UPGRADE
	
	else:
		if not Save.data.has("max_stamina"): Save.data["max_stamina"] = REAPER.MAX_STAMINA
		Save.data["max_stamina"] += UPGRADE
		REAPER.MAX_STAMINA = Save.data["max_stamina"]
		REAPER.STAMINA += UPGRADE
		
	Save.data[self.name] = true
	Save.save_game()

func _ready() -> void:
	
	if Save.data.has(self.name) and Save.data[self.name] == true:
		queue_free()
	
