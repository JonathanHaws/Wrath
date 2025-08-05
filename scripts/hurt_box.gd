extends Node
@export var damage = 1
@export var damage_spread := 0
@export var show_damage_numbers = false
@export var hurt_animation := "HURT" 
@export var death_animation := "DEATH"
# Add groups to this node you dont want it to damage to

func get_damage() -> int:
	return damage + randi_range(-damage_spread, damage_spread)

func show_damage(damage_amount: int) -> void:
	if show_damage_numbers:
		WorldUI.show_symbol(self.global_position, 140.0, "Node2D/Label", damage_amount)
		
