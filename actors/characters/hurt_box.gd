extends Node
@export var damage = 1
@export var damage_spread := 0
@export var damage_multiplier = 1
@export var damage_numbers: PackedScene = preload("uid://dx5gfq7hao3tx")
@export var hurt_animation := "HURT" 
@export var death_animation := "DEATH"
# Add groups to this node you dont want it to damage to

@export_group("Save")
@export var save_damage: bool = false
@export var save_key: String = ""
@export var animation_player: AnimationPlayer
@export var upgrade_animation: String = ""

func get_damage() -> int:
	return damage + randi_range(-damage_spread, damage_spread)

func show_damage(damage_amount: int) -> void:
	if damage_numbers: #
		var number = damage_numbers.instantiate()
		number.get_node("Node2D/Label").text = str(int(damage_amount))
		get_tree().current_scene.add_child(number)
		number.position = get_viewport().get_camera_3d().unproject_position(self.global_position) - Vector2(0, 140.0)
		
#func _process(_delta: float) -> void:
	#print(damage)

func _exit_tree() -> void:
	if not save_damage: return
	Save.data[save_key] = damage
	Save.save_game()

func _on_save_data_updated() -> void:
	if not save_damage: return
	if Save.data[save_key] != damage:
		if animation_player and animation_player.has_animation(upgrade_animation):
			animation_player.play(upgrade_animation)
	damage = Save.data[save_key]

func _ready() -> void:
	if not save_damage: return
	if save_key == "": save_key = Save.get_unique_key(self, "damage")
	if Save.data.has(save_key):
		damage = Save.data[save_key]
	else:
		Save.data[save_key] = damage
	Save.connect("save_data_updated", _on_save_data_updated)
