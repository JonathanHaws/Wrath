extends Area3D
signal DIED; signal HURT; signal HEAL
@export_group("Health")
@export var DISABLED: bool = false 
@export var HEALTH :float = 500.0
@export var MAX_HEALTH	:float = 500.0
@export var INVINCIBILITY_COOLDOWN: float = 0.05 ## After object gets hit how long they are invincible
@export var ROOT: Node ## Root of scene that will be freed if health is less then 0 when scene loaded in ready
@export var IMMUNE_GROUPS: Array[String] = [] ## Groups of hurtboxes in which this scene is immune to
func add_immune_group(group_name: String) -> void:
	if not group_name in IMMUNE_GROUPS:
		IMMUNE_GROUPS.append(group_name)
var invincibility_timer: Timer
var last_hurt_shape

@export_group("Save")
@export_subgroup("Health") ## Used to make it so health  is persistent across scenes
@export var SAVE_HEALTH: bool = false ## Most entities you want queue freed if health < 0 in ready... except player sometimes (Only works if Root Is Specified)
@export var HEALTH_KEY: String = "" ## The unique key used in save dictionary. If left empty will just use scene prefixed unique node path
func get_health_key() -> String:
	if HEALTH_KEY.is_empty(): return Save.get_unique_key(self, "health")
	else: return HEALTH_KEY
func _load_health() -> void:
	if not SAVE_HEALTH: return
	if Save.data.has(get_health_key()): 
		HEALTH = Save.data[get_health_key()]	

@export_subgroup("Save Max Health") 
@export var SAVE_MAX_HEALTH: bool = false ## Used for upgradable health
@export var MAX_HEALTH_KEY: String = "" ## The unique key used in save dictionary
func get_max_health_key() -> String:
	if MAX_HEALTH_KEY.is_empty(): return Save.get_unique_key(self, "max_health")
	else: return MAX_HEALTH_KEY
func _check_max_health() -> void: 
	# When save data is updated and fires a singal checks if max health has changed
	#var difference = Save.data[get_max_health_key()] - MAX_HEALTH Upgrade animation
	#if difference <= 0: return
	#if ANIMATION_PLAYER and UPGRADE_ANIMATION != "":
		#ANIMATION_PLAYER.play(UPGRADE_ANIMATION)
	MAX_HEALTH = Save.data[get_max_health_key()]
func _load_max_health() -> void:
	if not SAVE_MAX_HEALTH: return 
	if not Save.data.has(get_max_health_key()): 
		Save.data[get_max_health_key()] = MAX_HEALTH
	MAX_HEALTH = Save.data[get_max_health_key()]
	Save.connect("save_data_updated", Callable(self, "_check_max_health"))	

@export_subgroup("Respawn") 
@export var RESPAWN_ON_DEATH: bool = false ## Makes it so entitiy resets save data when player dies
@export var RESPAWN_ON_REST: bool = false ## Makes it so entitiy resets save data when player rests
@export var RESPAWN_TO_MAX_HEALTH: bool = true ## Increases health to max on death or respawn
@export var DEATHS_KEY: String = "deaths" ## What save key keeps track of players deaths
@export var RESTS_KEY: String = "rests" ## What save key keeps track of players rests 
@export var DEATH_COUNT_KEY: String = "" ## What save key keeps track of this entities deaths
@export var REST_COUNT_KEY: String = "" ## What save key keeps track of this entities rests 
@onready var initial_health: float = HEALTH
func _update_respawn_counter(counter_key: String, total_key: String) -> void:
	var total = Save.data.get(total_key, 0) 
	
	if not Save.data.has(counter_key): 	
		Save.data[counter_key] = total + 1
		return # first time spawning in set when to respwan and return
		
	if Save.data[counter_key] > total:
		return # not yet reached respawn count return
	
	Save.data[counter_key] = total + 1
	Save.data.erase(get_health_key())
	if RESPAWN_TO_MAX_HEALTH: HEALTH = Save.data.get(get_max_health_key(), MAX_HEALTH)
	else: HEALTH = initial_health
func _load_respawns() -> void:
	if DEATH_COUNT_KEY.is_empty(): DEATH_COUNT_KEY = Save.get_unique_key(self, "death_respawn")
	if REST_COUNT_KEY.is_empty(): REST_COUNT_KEY = Save.get_unique_key(self, "rest_respawn")
	if RESPAWN_ON_DEATH: _update_respawn_counter(DEATH_COUNT_KEY, DEATHS_KEY)
	if RESPAWN_ON_REST: _update_respawn_counter(REST_COUNT_KEY, RESTS_KEY)

@export_group("Damaged")  
@export_subgroup("Particles") 
@export var DAMAGE_NUMBERS: PackedScene 
@export var TELEPORT_NODES_TO_HIT: Array[Node3D] = [] ## For hurt particles
func show_damage(damage_amount: int) -> void:
	if not DAMAGE_NUMBERS: return
	var number = DAMAGE_NUMBERS.instantiate()
	number.get_node("Node2D/Label").text = str(int(damage_amount))
	get_tree().current_scene.add_child(number)
	number.position = get_viewport().get_camera_3d().unproject_position(self.global_position) - Vector2(0, 140.0)
func teleport_nodes_to_hit_source(hit_source: Area3D) -> void:
	for node in TELEPORT_NODES_TO_HIT:
		node.global_transform.origin = hit_source.global_transform.origin

@export_subgroup("Animation") 
@export var ANIM_PLAYER: AnimationPlayer
@export var HURT_ANIM: String = "HURT"
@export var DEATH_ANIM: String = "DEATH"
@export var HEAL_ANIM: String = "HEAL"
func _play_anim(anim: String, signal_to_emit: Signal) -> void:
	if not ANIM_PLAYER: # Automatically find player if one doesn't exist
		for child in get_children(): if child is AnimationPlayer:
			ANIM_PLAYER = child; break
	if not ANIM_PLAYER: return	
	if not ANIM_PLAYER.has_animation(anim): return
	if ANIM_PLAYER.current_animation == anim: return
	ANIM_PLAYER.play(anim)
	signal_to_emit.emit()

func hit(area: Area3D = null, damage: int = 0, play_animation: bool = true) -> bool:
	if DISABLED: 
		return false
	if invincibility_timer: 
		if invincibility_timer.is_stopped() == false: return false 
	if area: for immune_group in IMMUNE_GROUPS: 
		if area.is_in_group(immune_group): 
			#print('hit but immune')
			return false
	if damage == 0: 
		return false

	HEALTH -= damage
	last_hurt_shape = area
	if HEALTH <= 0: DISABLED = true
	if invincibility_timer: invincibility_timer.start()
	
	show_damage(damage)
	teleport_nodes_to_hit_source(area)
	if HEALTH <= 0 and play_animation: _play_anim(DEATH_ANIM, DIED)
	elif damage > 0 and play_animation: _play_anim(HURT_ANIM, HURT)
	elif damage < 0 and play_animation: _play_anim(HEAL_ANIM, HEAL)
	return true
		
func _ready():
	
	if INVINCIBILITY_COOLDOWN > 0:
		invincibility_timer = Timer.new()
		invincibility_timer.one_shot = true
		invincibility_timer.wait_time = INVINCIBILITY_COOLDOWN
		add_child(invincibility_timer)
		
	_load_max_health()			
	_load_respawns()	
	_load_health()
	
	if HEALTH <= 0 and ROOT: 
		ROOT.queue_free()

@export_group("Wave Health Bar") ## For bosses or encounters that spawn waves of enemies
@export var USE_WAVE_HEALTH_BAR: bool = false ## optional group for wave health
@export var WAVE_HITSHAPE_GROUP: String = "enemy_hitshape" ## optional group for wave health
@export var WAVE_DAMAGE :float = 300.0 ## The amount to decrease health when enemies die
		
func _process(_delta):
	#print(HEALTH)
	
	if USE_WAVE_HEALTH_BAR:
		var callback := Callable(self, "hit").bind(null, WAVE_DAMAGE)
		for e in get_tree().get_nodes_in_group(WAVE_HITSHAPE_GROUP):
			if e != self and not e.DIED.is_connected(callback):
				e.DIED.connect(callback)
	
func _exit_tree() -> void:
	if SAVE_HEALTH: 
		Save.data[get_health_key()] = HEALTH 
		Save.save_game()
