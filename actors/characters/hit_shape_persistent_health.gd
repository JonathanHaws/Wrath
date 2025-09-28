extends Node
@export var HIT_SHAPE: Node ## Hit shape that will store health inbetween scenes
@export var BODY: Node ## Root of scene that will be freed if health is less then 0

@export var STORE_DEAD: bool = true ## Most entities you want queue freed if health < 0 except player sometimes
@export var HEALTH_KEY: String = "" ## What save key to store health in between scenes being loaded / unloaded. If left empty will just use unique node path

@export_group("RESPAWN WHEN SAVE KEY INCREMENTS") ## For resetting health when player dies or rests
@export var RESPAWN_WHEN_DEATHS_INCREMENT: bool = true
@export var DEATH_COUNT_KEY: String = "" ## What save key keeps track of this entities deaths
@export var DEATHS_KEY: String = "deaths" ## What save key keeps track of players deaths
@export var RESPAWN_WHEN_RESTS_INCREMENT: bool = true
@export var REST_COUNT_KEY: String = "" ## What save key keeps track of this entities rests 
@export var RESTS_KEY: String = "rests" ## What save key keeps track of players rests 
func _load_respawn(counter_key: String, total_key: String) -> void: # Checks in ready for if its updated. If so resets health
	var total = Save.data.get(total_key, 0) 
	if Save.data.has(counter_key):
		if Save.data[counter_key] <= total:
			Save.data[counter_key] = total + 1
			if Save.data.has(HEALTH_KEY): Save.data.erase(HEALTH_KEY)
	else:
		Save.data[counter_key] = total + 1

@export_group("UPGRADABLE MAX HEALTH REACTION")
@export var UPGRADABLE_MAX_HEALTH: bool = false
@export var MAX_HEALTH_KEY: String = ""
@export var ANIMATION_PLAYER: AnimationPlayer ## Animation to play when upgrade is gotten (Should probably be in collectable)
@export var UPGRADE_ANIMATION: String ## Name of upgrade animation to play
func _check_max_health() -> void: # When save data is updated and fires a singal checks if max health has changed
	var difference = Save.data[MAX_HEALTH_KEY] - HIT_SHAPE.MAX_HEALTH
	if difference <= 0: return
	if ANIMATION_PLAYER and UPGRADE_ANIMATION != "":
		ANIMATION_PLAYER.play(UPGRADE_ANIMATION)
	HIT_SHAPE.MAX_HEALTH = Save.data[MAX_HEALTH_KEY]
func _load_max_health() -> void:
	if not UPGRADABLE_MAX_HEALTH: return # Keep default max health for entity
	if not Save.data.has(MAX_HEALTH_KEY): Save.data[MAX_HEALTH_KEY] = HIT_SHAPE.MAX_HEALTH
	HIT_SHAPE.MAX_HEALTH = Save.data[MAX_HEALTH_KEY]
	Save.connect("save_data_updated", Callable(self, "_check_max_health"))	

func _ready() -> void:
	
	if HEALTH_KEY.is_empty(): HEALTH_KEY = Save.get_unique_key(self, "health")
	if DEATH_COUNT_KEY.is_empty(): DEATH_COUNT_KEY = Save.get_unique_key(self, "death_respawn")
	if REST_COUNT_KEY.is_empty(): REST_COUNT_KEY = Save.get_unique_key(self, "rest_respawn")
	if MAX_HEALTH_KEY.is_empty(): MAX_HEALTH_KEY = Save.get_unique_key(self, "max_health")
	
	if RESPAWN_WHEN_DEATHS_INCREMENT: _load_respawn(DEATH_COUNT_KEY, DEATHS_KEY)
	if RESPAWN_WHEN_RESTS_INCREMENT: _load_respawn(REST_COUNT_KEY, RESTS_KEY)
	
	_load_max_health()	
					
	if HEALTH_KEY.is_empty(): HEALTH_KEY = Save.get_unique_key(self, "health")
	if Save.data.has(HEALTH_KEY): HIT_SHAPE.HEALTH = Save.data[HEALTH_KEY]	
	else: HIT_SHAPE.HEALTH = HIT_SHAPE.MAX_HEALTH
	if HIT_SHAPE.HEALTH <= 0 and BODY: BODY.queue_free()

func _exit_tree() -> void: # Store when switching between scenes
	if not HIT_SHAPE: return
	Save.data[HEALTH_KEY] = HIT_SHAPE.HEALTH 
	Save.save_game()
		
