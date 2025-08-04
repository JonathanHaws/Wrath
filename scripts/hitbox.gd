extends Node
@export var BODY: Node3D
@export var SAVE_KEY_PLAYER_DEATHS: String = "deaths"
@export var SAVE_HEALTH: bool = false
@export var HEALTH_KEY: String = ""
@export var RESPAWN: bool = false
@export var RESPAWN_KEY: String = ""
@export var DEFEATED_KEY: String = ""

func _ready()-> void:
	
	if HEALTH_KEY.is_empty(): HEALTH_KEY = Save.get_unique_key(self, "health")
	if RESPAWN_KEY.is_empty(): RESPAWN_KEY = Save.get_unique_key(self, "respawn_at_deathcount")
	if DEFEATED_KEY.is_empty(): DEFEATED_KEY = Save.get_unique_key(self, "defeated")
	
	if RESPAWN:
		if Save.data.has(RESPAWN_KEY):
			if int(Save.data[RESPAWN_KEY]) <= int(Save.data[SAVE_KEY_PLAYER_DEATHS]):
				Save.data[RESPAWN_KEY] = int(Save.data[SAVE_KEY_PLAYER_DEATHS]) + 1
				Save.data.erase(HEALTH_KEY)
				Save.data.erase(DEFEATED_KEY)
			
	if SAVE_HEALTH and Save.data.has(HEALTH_KEY):
		BODY.HEALTH = Save.data[HEALTH_KEY]
			 			
	if Save.data.has(DEFEATED_KEY):
		BODY.queue_free()
			
func _exit_tree() -> void:
	
	if BODY.HEALTH >= BODY.MAX_HEALTH:
		Save.data.erase(HEALTH_KEY)
	else:
		Save.data.erase(DEFEATED_KEY)
		Save.data[HEALTH_KEY] = BODY.HEALTH

	if BODY.HEALTH <= 0:
		
		Save.data.erase(HEALTH_KEY)
		Save.data[DEFEATED_KEY] = true
		
		if RESPAWN: Save.data[RESPAWN_KEY] = int(Save.data[SAVE_KEY_PLAYER_DEATHS]) + 1
	
	Save.save_game()
