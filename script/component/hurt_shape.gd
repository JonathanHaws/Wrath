extends Area3D
@export var groups: Array[String] = ["enemies"] ## Groups that are auto added in ready
@export var disable_collision_shape: bool = false ## automatically sets collision shape to disabled in ready
@export var damage: float = 10.0
@export var damage_spread: float = 0 ## Determines subtle randomness in attack damage
@export var damage_multiplier: float = 1 ## Value that can be animated by animation players 
@export var hit_anim: String = "HURT" ## Name of the animation to play when something is hit
@export var kill_anim: String = "KILL" ## Name of animation to play when something is killed
@export var animation_player: AnimationPlayer ## Animation to be played when something is hit by this hurt shape
@export var hit_shape: Area3D ## Avoid damagining after death by automatocally freeing this hurtbox when this hitshape dies
signal collided_with_hitshape
var overlapping_hit_areas: Dictionary = {}

@export_group("Blocking")
@export var parryable: bool = false
@export var parry_window: float = 0.15 ## seconds
@export var blocked_anim: String = "BLOCKED"
@export var parry_anim: String = "PARRY"
@export var deflected_anim_player: AnimationPlayer
@export var block_groups: Array[String] = ["player_blockshape"]
var overlapping_block_areas: Dictionary = {}
func is_block_area(area: Area3D) -> bool:
	for group in block_groups: if area.is_in_group(group): return true
	return false	
func get_best_block() -> Dictionary:
	var best_area: Area3D = null
	var lowest_multiplier: float = 1.0
	for block_area in overlapping_block_areas.keys():
		if not is_instance_valid(block_area): continue
		var multiplier: float = block_area.block_multiplier
		if parryable and "enabled_time" in block_area and block_area.enabled_time < parry_window:
			multiplier = 0.0
		if best_area == null or multiplier < lowest_multiplier:
			best_area = block_area
			lowest_multiplier = multiplier
	return { "area": best_area, "multiplier": lowest_multiplier }
	
func play_blocked_animation(block_area: Area3D, blocked_damage_multiplier: float) -> void:
	if not deflected_anim_player: return
	if blocked_damage_multiplier == 0.0:
		if deflected_anim_player.has_animation(parry_anim): deflected_anim_player.play(parry_anim, 0)
		deflected_anim_player.advance(0.0)
	elif blocked_damage_multiplier < 1.0:
		if deflected_anim_player.has_animation(blocked_anim): deflected_anim_player.play(blocked_anim, 0)
		deflected_anim_player.advance(0.0)	
	if block_area and block_area.has_method("play_blocked_animation"):
		block_area.play_blocked_animation()
			
@export_group("Save") ## For upgradable damage that needs to be persisten / update
@export var enable_save: bool = false
@export var save_key: String = ""
func _exit_tree() -> void:
	if not enable_save: return
	Save.data[save_key] = damage
	Save.save_game()
func _on_save_data_updated() -> void:
	#if Save.data[save_key] != damage: #upgrade animation 
	if not Save.data.has(save_key): return
	damage = Save.data[save_key]
	damage_multiplier = 1.0
	#print(damage)
	
@export_group("New Game Modifier")
@export var SCALE_DAMAGE: bool = true
@export var DAMAGE_SCALE_KEY: String = "enemy_damage_multiplier"	
func get_damage_scale_multiplier() -> float:
	if not SCALE_DAMAGE: return 1.0
	return float(Save.data.get(DAMAGE_SCALE_KEY, 1.0))
	
func save_ready() -> void:
	if not enable_save: return
	if save_key == "": save_key = Save.get_unique_key(self, "damage")
	if Save.data.has(save_key): damage = Save.data[save_key]
	else: Save.data[save_key] = damage
	Save.connect("save_data_updated", _on_save_data_updated)

func play_animation(area: Area3D) -> void:
	if not animation_player: return
	if "HEALTH" in area and area.HEALTH <= 0: animation_player.play(kill_anim)
	else: animation_player.play(hit_anim)

func _ready() -> void:	
	for group in groups: add_to_group(group)
	if hit_shape and hit_shape.has_signal("DIED"): hit_shape.DIED.connect(queue_free)
	if disable_collision_shape: $CollisionShape3D.disabled = true
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	save_ready()

func _on_area_entered(area: Area3D) -> void:
	if overlapping_block_areas.has(area) or overlapping_hit_areas.has(area): return
	if is_block_area(area): overlapping_block_areas[area] = false
	
	#for group in groups: 
		#if area.is_in_group(group): 
			#return
	if area.has_method("hit"): overlapping_hit_areas[area] = false

func _on_area_exited(area: Area3D) -> void:
	overlapping_block_areas.erase(area)
	
func _physics_process(_delta: float) -> void:
	#if overlapping_hit_areas.size() > 0: print(overlapping_hit_areas)

	if $CollisionShape3D.disabled: overlapping_hit_areas.clear()	
			
	for area in overlapping_hit_areas.keys():
		if not is_instance_valid(area): continue
		if overlapping_hit_areas[area]: continue # Already attacked with this area
		overlapping_hit_areas[area] = true
	
		#overlapping_hit_areas[area] = true
		#var best_block = get_best_block()
		#play_blocked_animation(best_block.area, best_block.multiplier)

		if area.has_method("hit"): emit_signal("collided_with_hitshape")
		if area.hit(self, int(damage + randf_range(-damage_spread, damage_spread)) * (damage_multiplier * get_damage_scale_multiplier())):
			play_animation(area)
