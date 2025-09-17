extends Node
@export var HIT_SHAPE: Node ## Hit shape that will store health inbetween scenes
@export var HEALTH_KEY: String = "" ## What save key to store health in between scenes being loaded / unloaded. If left empty will just use unique node path

@export var BODY: Node
@export var FREE_BODY_IF_DEAD_ON_READY: bool = true

@export var RESPAWN: bool = false
@export var RESPAWN_KEY: String = "" ## key for when object will respawn. If kept empty a key will be generated automatically by unique node path
@export var PLAYER_DEATH_COUNT_KEY: String = "deaths" ## Respawn when this increments... By erasing any save data related to health

func _ready() -> void:
	if HEALTH_KEY.is_empty(): HEALTH_KEY = Save.get_unique_key(self, "health")
	if RESPAWN_KEY.is_empty(): RESPAWN_KEY = Save.get_unique_key(self, "respawn_at_deathcount")
	
	if RESPAWN:
		var death_count = int(Save.data.get(PLAYER_DEATH_COUNT_KEY, 0))
		if not Save.data.has(RESPAWN_KEY): Save.data[RESPAWN_KEY] = death_count + 1
		
		if death_count >= Save.data[RESPAWN_KEY]: #RESET SAVE DATA 
			#print("respawn")
			Save.data.erase(RESPAWN_KEY)
			Save.data.erase(HEALTH_KEY)
		
	if Save.data.has(HEALTH_KEY): HIT_SHAPE.HEALTH = Save.data[HEALTH_KEY]
		
	if FREE_BODY_IF_DEAD_ON_READY and HIT_SHAPE.HEALTH <= 0 and BODY: BODY.queue_free()
	
func _exit_tree() -> void:
	if HIT_SHAPE and HEALTH_KEY != "":
		Save.data[HEALTH_KEY] = HIT_SHAPE.HEALTH
		Save.save_game()
		
