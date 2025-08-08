extends Node
@export var damage = 1
@export var damage_spread := 0
@export var damage_numbers: PackedScene = preload("uid://dx5gfq7hao3tx")
@export var hurt_animation := "HURT" 
@export var death_animation := "DEATH"
# Add groups to this node you dont want it to damage to

func get_damage() -> int:
	return damage + randi_range(-damage_spread, damage_spread)

func show_damage(damage_amount: int) -> void:
	if damage_numbers: #
		var number = damage_numbers.instantiate()
		number.get_node("Node2D/Label").text = str(int(damage_amount))
		get_tree().current_scene.add_child(number)
		number.position = get_viewport().get_camera_3d().unproject_position(self.global_position) - Vector2(0, 140.0)
		
