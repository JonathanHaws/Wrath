extends Area3D
@export var damage = 1
@export var damage_spread := 0
@export var damage_multiplier = 1
@export var damage_groups: Array[String] = ["player_hitshape"] ##area groups you want this hurtbox to damage
signal hurt_something

func _on_area_entered(area: Area3D) -> void:
	for group in damage_groups:
		if area.is_in_group(group):
			#print("hit")
			if "hit" in area:
				#print("hit", damage)
				area.hit(self, (damage + randi_range(-damage_spread, damage_spread)) * damage_multiplier)
			emit_signal("hurt_something")
			break

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
