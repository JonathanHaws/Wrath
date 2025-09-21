extends Node
@export var hurt_shape: Node
@export var save_key: String = ""
@export var animation_player: AnimationPlayer
@export var upgrade_animation: String = ""

func _exit_tree() -> void:
	Save.data[save_key] = hurt_shape.damage
	Save.save_game()
	
func _on_save_data_updated() -> void:
	if Save.data[save_key] != hurt_shape.damage:
		if animation_player and animation_player.has_animation(upgrade_animation):
			animation_player.play(upgrade_animation)
	hurt_shape.damage = Save.data[save_key]
	
func _ready() -> void:
	
	if save_key == "": save_key = Save.get_unique_key(self, "damage")
	if Save.data.has(save_key): hurt_shape.damage = Save.data[save_key]
	else: Save.data[save_key] = hurt_shape.damage
	
	Save.connect("save_data_updated", _on_save_data_updated)
	
#func _process(delta: float) -> void:
	#print(hurt_shape.damage)
