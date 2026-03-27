extends Area3D
@export var groups: Array[String] = ["enemies"] ## Groups that are auto added in ready
@export_group("Damage")
@export var disabled: bool = false
@export var damage: float = 10.0
@export var damage_spread: float = 0 ## Determines subtle randomness in attack damage
@export var damage_multiplier: float = 1 ## Value that can be animated by animation players 
@export var cooldown: float = 0.2 

@export_group("Linger")
@export var linger: bool = false
@export var linger_tick: float = 1.0
@export var hit_shape: Area3D ## Avoid lingering by automatocally freeing this hurtbox when this hitshape dies

@export_group("Animation")
@export var animation_player: AnimationPlayer ## Animation to be played when something is hit by this hurt shape
@export var hit_anim: String = "HURT" ## Name of the animation to play when something is hit
@export var kill_anim: String = "KILL" ## Name of animation to play when something is killed
func play_animation(area: Area3D) -> void:
	#if not animation_player: # Auto find a child if one doesn't exist (Convient)
		#for child in get_children(): if child is AnimationPlayer:
			#animation_player = child
			#break	
	
	if not animation_player: return
	if "HEALTH" in area and area.HEALTH <= 0:
		if animation_player.has_animation(kill_anim):
			animation_player.play(kill_anim)
	else:
		animation_player.play(hit_anim)
var overlapping_areas: Dictionary = {}
signal hurt_something

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
func is_block_area_in_overlapping_areas() -> Area3D:
	for node in overlapping_areas: if is_block_area(node): return node
	return null	
func get_block_area_in_overlapping_areas() -> Area3D:
	for node in overlapping_areas.keys(): if is_block_area(node): return node
	return null
func blocked(area: Area3D) -> float:
	#print(area.name)
	if area.has_method("play_blocked_animation"):
		area.play_blocked_animation()  
	
	if deflected_anim_player: 
		var parried: bool = parryable and "enabled_time" in area and area.enabled_time < parry_window
		if parried: 
			if deflected_anim_player.has_animation(parry_anim) and deflected_anim_player.current_animation != parry_anim:
				deflected_anim_player.play(parry_anim)
				#print('parried')
		else: # regular block
			if deflected_anim_player.has_animation(blocked_anim) and deflected_anim_player.current_animation != blocked_anim:
				deflected_anim_player.play(blocked_anim)
				#print('blocked')
	
	return get_block_area_in_overlapping_areas().block_multiplier
					
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

func hurt(area: Area3D) -> void:
	if disabled: return
	await get_tree().physics_frame # Ensure both the regular hit_shape AND block_shape is in 'overlapping areas;
	if area not in overlapping_areas: return
	#print("Cooldown remaining:", overlapping_areas[area]["cooldown"].is_stopped())
	if not overlapping_areas[area]["cooldown"].is_stopped(): return
	
	# blocking
	var unblocked_damage_multiplier = 1.0
	var block_area = is_block_area_in_overlapping_areas()
	if block_area: unblocked_damage_multiplier = blocked(block_area)
	
	if area.hit(self, int(damage + randf_range(-damage_spread, damage_spread)) * (damage_multiplier * unblocked_damage_multiplier)):
		emit_signal("hurt_something")
		overlapping_areas[area]["cooldown"].start()
		overlapping_areas[area]["linger"].start() 
		overlapping_areas[area]["linger"].start() 
		play_animation(area)
			
func _on_area_entered(area: Area3D) -> void:
	
	if is_block_area(area): overlapping_areas[area] = {}; # add block overlapping
	if !"hit" in area: return ## Make sure it can be hurt
	if area in overlapping_areas: return ## Already inside
	for group in groups: if area.is_in_group(group): return ## Dont attack self
	
	var cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	add_child(cooldown_timer)
	#cooldown_timer.add_to_group("memory_leak_check")

	var linger_timer = Timer.new()
	linger_timer.wait_time = linger_tick
	add_child(linger_timer)
	if linger: linger_timer.timeout.connect(func() -> void: hurt(area))
	#linger_timer.add_to_group("memory_leak_check")

	overlapping_areas[area] = { "cooldown": cooldown_timer, "linger": linger_timer }
	 
	hurt(area)

func _on_area_exited(area: Area3D) -> void:
	if area in overlapping_areas: # Clean up potential memory leak
		for t in overlapping_areas[area].values(): t.queue_free() 
		overlapping_areas.erase(area)

func _ready() -> void:
	for group in groups: add_to_group(group)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	save_ready()
	
	if hit_shape and hit_shape.has_signal("DIED"):
		hit_shape.DIED.connect(queue_free)
	
#func _process(_delta: float) -> void:
	#print("Timers alive:", get_tree().get_nodes_in_group("memory_leak_check").size())

#func _process(_delta: float) -> void:
	#print("Timers alive:", get_tree().get_nodes_in_group("memory_leak_check").size())
