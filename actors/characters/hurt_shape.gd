extends Area3D
@export var damage :float = 10.0
@export var damage_spread := 0
@export var damage_multiplier: float = 1
@export var damage_groups: Array[String] = ["player_hitshape"] ##area groups you want this hurtbox to damage
@export var hit_animation_player: AnimationPlayer
@export var hit_anim: String = "HIT"
@export var cooldown: float = 0.2
var cooldown_timer: Timer

signal hurt_something

func _on_area_entered(area: Area3D) -> void:
	if cooldown_timer.is_stopped() == false: return
	
	for group in damage_groups:
		if area.is_in_group(group):
			#print("hit")
			if "hit" in area:
				#print("hit", damage)
				if area.hit(self, int(damage + randi_range(-damage_spread, damage_spread)) * damage_multiplier):
					cooldown_timer.start()
					
					emit_signal("hurt_something")
					if hit_animation_player:
						#print('playing')
						hit_animation_player.play(hit_anim)		
					break

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	
