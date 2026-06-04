extends Area3D
@export var groups: Array[String] = ["enemies"] ## Groups that are auto added in ready
@export_group("Damage")
@export var disabled: bool = false
@export var damage: float = 10.0
@export var damage_spread: float = 0 ## Determines subtle randomness in attack damage
@export var damage_multiplier: float = 1 ## Value that can be animated by animation players 
@export var disable_collision_shape: bool = false ## automatically sets collision shape to disabled in ready
@export var hit_shape: Area3D ## Avoid damagining after death by automatocally freeing this hurtbox when this hitshape dies
@export var animation_player: AnimationPlayer ## Animation to be played when something is hit by this hurt shape
@export var hit_anim: String = "HURT" ## Name of the animation to play when something is hit
@export var kill_anim: String = "KILL" ## Name of animation to play when something is killed
signal collided_with_hitshape
var overlapping_hit_areas: Dictionary = {}
var overlapping_block_areas: Dictionary = {}

@export_group("Blocking")
@export var parryable: bool = false
@export var parry_window: float = 0.15 ## seconds
@export var blocked_anim: String = "BLOCKED"
@export var parry_anim: String = "PARRY"
@export var deflected_anim_player: AnimationPlayer
@export var block_groups: Array[String] = ["player_blockshape"]
func is_block_area(area: Area3D) -> bool:
	for group in block_groups: if area.is_in_group(group): return true
	return false
#func blocked(area: Area3D) -> float:
	##print(area.name)
	#if area.has_method("play_blocked_animation"):
		#area.play_blocked_animation()  
	#
	#if deflected_anim_player: 
		#var parried: bool = parryable and "enabled_time" in area and area.enabled_time < parry_window
		#if parried: 
			#if deflected_anim_player.has_animation(parry_anim) and deflected_anim_player.current_animation != parry_anim:
				#deflected_anim_player.play(parry_anim)
				##print('parried')
		#else: # regular block
			#if deflected_anim_player.has_animation(blocked_anim) and deflected_anim_player.current_animation != blocked_anim:
				#deflected_anim_player.play(blocked_anim)
				##print('blocked')
	#
	#return get_block_area_in_overlapping_areas().block_multiplier	
					
@export_group("Save") ## For upgradable damage that needs to be persisten / update
@export var enable_save: bool = false
@export var save_key: String = ""
func _exit_tree() -> void:
	if not enable_save: return
	Save.data[save_key] = damage
	Save.save_game()
func _on_save_data_updated() -> void:
	#if Save.data[save_key] != damage: #upgrade animation 
	damage = Save.data[save_key]
	damage_multiplier = 1.0
	#print(damage)
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
	if area.has_method("hit"): overlapping_hit_areas[area] = false

func _on_area_exited(area: Area3D) -> void:
	overlapping_block_areas.erase(area)
	
func _physics_process(_delta: float) -> void:
	#if overlapping_hit_areas.size() > 0: print(overlapping_hit_areas)
		
	if disabled: return		
	for area in overlapping_hit_areas.keys():
	
		if overlapping_hit_areas[area]:
			if $CollisionShape3D.disabled: overlapping_hit_areas.erase(area)
			continue
	
		## blocking
		var unblocked_damage_multiplier = 1.0
		#var block_area = is_block_area_in_overlapping_areas()
		#if block_area: unblocked_damage_multiplier = blocked(block_area)
		
		if area.has_method("hit"): emit_signal("collided_with_hitshape")
		if area.hit(self, int(damage + randf_range(-damage_spread, damage_spread)) * (damage_multiplier * unblocked_damage_multiplier)):
			play_animation(area)
			overlapping_hit_areas[area] = true


		
