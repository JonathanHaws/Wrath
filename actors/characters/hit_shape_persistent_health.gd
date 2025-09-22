extends Node
@export var HIT_SHAPE: Node ## Hit shape that will store health inbetween scenes
@export var BODY: Node ## Root of scene that will be freed if health is less then 0
@export var STORE_DEAD: bool = true ## Most entities you want queue freed if health < 0 except player sometimes

@export var HEALTH_KEY: String = "" ## What save key to store health in between scenes being loaded / unloaded. If left empty will just use unique node path
@export var RESPAWN_DATA_KEY: String = "respawn_data" ## Substruct to save struct where all data that gets deleted at rest or death is kept

func _ready() -> void:
	if HEALTH_KEY.is_empty(): HEALTH_KEY = Save.get_unique_key(self, "health")

	if Save.data.has(RESPAWN_DATA_KEY) and Save.data[RESPAWN_DATA_KEY].has(HEALTH_KEY):
		HIT_SHAPE.HEALTH = Save.data[RESPAWN_DATA_KEY][HEALTH_KEY]
		
	if HIT_SHAPE.HEALTH <= 0 and BODY: BODY.queue_free()

func _exit_tree() -> void: # Store when switching between scenes
	if HIT_SHAPE and HEALTH_KEY != "":
		if not Save.data.has(RESPAWN_DATA_KEY): Save.data[RESPAWN_DATA_KEY] = {}
		Save.data[RESPAWN_DATA_KEY][HEALTH_KEY] = HIT_SHAPE.HEALTH
		
		if HIT_SHAPE.HEALTH <= 0 and not STORE_DEAD:
			Save.data[RESPAWN_DATA_KEY].erase(HEALTH_KEY)
			
		Save.save_game()
		
