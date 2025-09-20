extends Area3D
@export var damage = 1
@export var damage_spread := 0
@export var damage_multiplier = 1
@export var damage_groups: Array[String] = ["player_hitshape"] ##area groups you want this hurtbox to damage

@export_group("Save")
@export var save_damage: bool = false
@export var save_key: String = ""
@export var animation_player: AnimationPlayer
@export var upgrade_animation: String = ""

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

func _on_area_entered(area: Area3D) -> void:
	for group in damage_groups:
		if area.is_in_group(group):
			#print("hit")
			if "hit" in area:
				#print("hit", damage)
				area.hit(self, damage + randi_range(-damage_spread, damage_spread))
			break

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	if save_damage: 
		if save_key == "": save_key = Save.get_unique_key(self, "damage")
		if Save.data.has(save_key):
			damage = Save.data[save_key]
		else:
			Save.data[save_key] = damage
		Save.connect("save_data_updated", _on_save_data_updated)
