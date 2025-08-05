extends Area3D
@export var HEALTH = 500
@export var MAX_HEALTH = 500
@export var BODY: Node3D
@export var IMMUNE_GROUPS: Array[String] = []

@export_group("SAVE DATA")
@export var SAVE_KEY_PLAYER_DEATHS: String = "deaths"
@export var SAVE_HEALTH: bool = false
@export var RESPAWN: bool = false
@export var SAVE_DEFEATED: bool = true
@export var STORE_DEATHCOUNT: bool = false
@export var HEALTH_KEY: String = ""
@export var RESPAWN_KEY: String = ""
@export var DEFEATED_KEY: String = ""
@export var DEATHCOUNT_KEY: String = ""
@export var LOAD_MAX_HEALTH: bool = false
@export var MAX_HEALTH_KEY: String = ""

@export_group("DAMAGE REACTION")
## For Body / Child Nodes which have to reposition themselves. Such as Needed positional synchronization between attacker / attacked on animations, Hurt Particles, etc.
@export var TELEPORT_NODES_TO_HIT: Array[Node3D] = [] 
@export var ANIMATION_PLAYERS: Array[AnimationPlayer] = []
@export var HURT_ANIM: String = "HURT"
@export var DEATH_ANIM: String = "DEATH"

func hit(area: Area3D) -> void:
	
	for immune_group in IMMUNE_GROUPS: # dont damage freinds or yourself
		if area.is_in_group(immune_group):
			return

	if not "get_damage" in area:
		return
	var damage = int(area.get_damage())
	HEALTH -= damage
	if "show_damage" in area and area.has_method("show_damage"):
		area.show_damage(damage)
	
	for node in TELEPORT_NODES_TO_HIT:
		node.global_transform.origin = area.global_transform.origin
		
	for anim_player in ANIMATION_PLAYERS:
		if HEALTH > 0 and anim_player.has_animation(area.hurt_animation):
			anim_player.play(area.hurt_animation)
		elif HEALTH <= 0 and anim_player.has_animation(area.death_animation):
			anim_player.play(area.death_animation)
			
	if HEALTH >= MAX_HEALTH:
		Save.data.erase(HEALTH_KEY)
		Save.data.erase(DEFEATED_KEY)
	elif HEALTH > 0:
		Save.data.erase(DEFEATED_KEY)
		Save.data[HEALTH_KEY] = HEALTH
		Save.save_game()
	else:
		Save.data.erase(HEALTH_KEY)
		if SAVE_DEFEATED: Save.data[DEFEATED_KEY] = true
		if RESPAWN: Save.data[RESPAWN_KEY] = int(Save.data[SAVE_KEY_PLAYER_DEATHS]) + 1
		if STORE_DEATHCOUNT: Save.data[DEATHCOUNT_KEY] = int(Save.data.get(DEATHCOUNT_KEY, 0)) + 1
		Save.save_game()

func _ready()-> void:
	
	if HEALTH_KEY.is_empty(): HEALTH_KEY = Save.get_unique_key(self, "health")
	if RESPAWN_KEY.is_empty(): RESPAWN_KEY = Save.get_unique_key(self, "respawn_at_deathcount")
	if DEFEATED_KEY.is_empty(): DEFEATED_KEY = Save.get_unique_key(self, "defeated")
	if DEATHCOUNT_KEY.is_empty(): DEATHCOUNT_KEY = Save.get_unique_key(self, "deaths_count")
	
	if RESPAWN:
		if Save.data.has(RESPAWN_KEY):
			if int(Save.data[RESPAWN_KEY]) <= int(Save.data[SAVE_KEY_PLAYER_DEATHS]):
				Save.data[RESPAWN_KEY] = int(Save.data[SAVE_KEY_PLAYER_DEATHS]) + 1
				Save.data.erase(HEALTH_KEY)
				Save.data.erase(DEFEATED_KEY)
			
	if SAVE_HEALTH and Save.data.has(HEALTH_KEY):
		HEALTH = Save.data[HEALTH_KEY]
			 			
	if SAVE_DEFEATED and Save.data.has(DEFEATED_KEY):
		BODY.queue_free()
		
	if LOAD_MAX_HEALTH and Save.data.has(MAX_HEALTH_KEY):
		MAX_HEALTH = Save.data[MAX_HEALTH_KEY]
		if not Save.data.has(HEALTH_KEY):
			HEALTH = MAX_HEALTH	
	
	area_entered.connect(hit)
			
#func  _physics_process(delta: float) -> void:
	#print(HEALTH)
