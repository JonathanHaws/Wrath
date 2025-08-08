extends Node
@export var save_key: String
@export var update_node: Node
@export var update_property: String
@export var copy_difference: bool = false
@export var animation_player: AnimationPlayer
@export var animation_name: String
var last_value = null

func _ready() -> void:
	if not update_node or update_property == "": return
		
	if Save.data.has(save_key):
		var saved_value = Save.data[save_key]
		update_node.set(update_property, saved_value)
		last_value = saved_value
	else:
		Save.data[save_key] = update_node.get(update_property)

func _physics_process(_delta):
	if not update_node or update_property == "":
		return
		
	if Save.data[save_key] != last_value:
		last_value = Save.data[save_key]
		update_node.set(update_property, Save.data[save_key])
		if animation_player and animation_name != "":
			animation_player.play(animation_name)
			
