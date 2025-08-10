extends Area3D
@export var HEALTH = 500
@export var MAX_HEALTH = 500
@export var BODY: Node3D
@export var IMMUNE_GROUPS: Array[String] = []

@export_group("SAVE HEALTH")
@export var SAVE_HEALTH: bool = false
@export var HEALTH_KEY: String = ""

@export_group("SAVE MAX HEALTH")
@export var SAVE_MAX_HEALTH: bool = false
@export var MAX_HEALTH_KEY: String = ""
@export var INCREASE_HEALTH_WHEN_MAX_HEALTH_INCREASED: bool = true
@export var ANIMATION_PLAYER: AnimationPlayer
@export var UPGRADE_ANIMATION: String

@export_group("RESPAWN")
@export var RESPAWN: bool = false
@export var DEATH_OFFSET: int = 1
@export var RESPAWN_KEY: String = ""
@export var PLAYER_DEATH_COUNT_KEY: String = "deaths"

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
			anim_player.play(area.hurt_animation,0)
		elif HEALTH <= 0 and anim_player.has_animation(area.death_animation):
			anim_player.play(area.death_animation,0)

func restore_health() -> void:
	HEALTH = MAX_HEALTH

func _exit_tree() -> void:
	
	if SAVE_HEALTH: Save.data[HEALTH_KEY] = HEALTH

	if RESPAWN:	
		if HEALTH > 0: 
			Save.data.erase(RESPAWN_KEY)
		else:
			if not Save.data.has(RESPAWN_KEY): # Dont keep moving goalpost for required player deaths to comeback
				Save.data[RESPAWN_KEY] = int(Save.data[PLAYER_DEATH_COUNT_KEY]) + DEATH_OFFSET
	
	Save.save_game()

func _on_save_data_updated() -> void:

	var difference = Save.data[MAX_HEALTH_KEY] - MAX_HEALTH
	if difference == 0: return  # Already equivalent dont show notification as property hasn't changed)

	if INCREASE_HEALTH_WHEN_MAX_HEALTH_INCREASED: HEALTH += difference
	
	if ANIMATION_PLAYER and UPGRADE_ANIMATION != "":
		ANIMATION_PLAYER.play(UPGRADE_ANIMATION)
		
	MAX_HEALTH = Save.data[MAX_HEALTH_KEY]

func _ready()-> void:
	
	if HEALTH_KEY.is_empty(): HEALTH_KEY = Save.get_unique_key(self, "health")
	if MAX_HEALTH_KEY.is_empty(): MAX_HEALTH_KEY = Save.get_unique_key(self, "max_health")
	if RESPAWN_KEY.is_empty(): RESPAWN_KEY = Save.get_unique_key(self, "respawn_at_deathcount")
	
	if SAVE_MAX_HEALTH:
		if Save.data.has(MAX_HEALTH_KEY):
			MAX_HEALTH = Save.data[MAX_HEALTH_KEY]
		else:
			Save.data[MAX_HEALTH_KEY] = MAX_HEALTH
		Save.connect("save_data_updated", _on_save_data_updated)
		
	if RESPAWN:
		if Save.data.has(RESPAWN_KEY):
			if int(Save.data[RESPAWN_KEY]) <= int(Save.data[PLAYER_DEATH_COUNT_KEY]):
				Save.data.erase(RESPAWN_KEY)
				Save.data.erase(HEALTH_KEY)
				HEALTH = MAX_HEALTH
					 			
	if SAVE_HEALTH and Save.data.has(HEALTH_KEY):
		HEALTH = Save.data[HEALTH_KEY]							
							
	if HEALTH < 0:
		BODY.queue_free()
	
	area_entered.connect(hit)
			
#func  _physics_process(delta: float) -> void:
	#print(HEALTH)
