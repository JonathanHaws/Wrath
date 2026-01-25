extends Area3D
@export var damage: float = 10.0
@export var damage_spread: float = 0 ## Determines subtle randomness in attack damage
@export var damage_multiplier: float = 1 ## Value that can be animated by animation players 
@export var damage_groups: Array[String] = ["player_hitshape"] ##area groups you want this hurtbox to damage
@export var hit_animation_player: AnimationPlayer ## Animation to be played when something is hit by this hurt shape
@export var hit_anim: String = "HURT" ## Name of the animation to play
@export var cooldown: float = 0.2 
@export var linger: bool = false
@export var linger_tick: float = 1.2
var overlapping_areas: Dictionary = {}
signal hurt_something

func hurt(area: Area3D) -> void:
	
	#print("Cooldown remaining:", overlapping_areas[area]["cooldown"].is_stopped())
	
	if area not in overlapping_areas: return
	if not overlapping_areas[area]["cooldown"].is_stopped(): return
	if !"hit" in area: return
	
	if area.hit(self, int(damage + randf_range(-damage_spread, damage_spread)) * damage_multiplier):
		emit_signal("hurt_something")
		if hit_animation_player: hit_animation_player.play(hit_anim)	
		overlapping_areas[area]["cooldown"].start()
		overlapping_areas[area]["linger"].start() 
			
func _on_area_entered(area: Area3D) -> void:
	
	var in_group := false # Verify in group
	for group in damage_groups:
		if area.is_in_group(group):
			in_group = true
			break
	if !in_group: return
	
	if area not in overlapping_areas:
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
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

#func _process(_delta: float) -> void:
	#print("Timers alive:", get_tree().get_nodes_in_group("memory_leak_check").size())
