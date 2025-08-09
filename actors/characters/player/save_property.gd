extends Node
## Key To update with
@export var max_save_key: String

@export_group("Update Node")
## Node that has the properties that want to stay always up to date with save data
@export var node: Node
## Property to contantly load save data. For example "max health"
@export var max_property: String
## Property to update with difference. For example "health"
@export var property: String
## When max health gets an upgrade does health get upgraded too?
@export var increase_property_by_max_difference: bool = false
## Sets property in ready... Sets health to max_health for example
@export var set_property_to_max_in_ready: bool = false

@export_group("Notification Animation")
## (Optional) Trigger upgrade notification with this player
@export var animation_player: AnimationPlayer
## Name Of Animation
@export var animation_name: String

func _on_save_data_updated() -> void:
	if not node or max_property == "": return
	if not Save.data.has(max_save_key): return
	
	var difference = Save.data[max_save_key] - node.get(max_property)
	if difference == 0: return  # Already equivalent dont show notification as property hasn't changed)

	if increase_property_by_max_difference and property != "":
		node.set(property, node.get(property) + difference)
	
	if animation_player and animation_name != "":
		animation_player.play(animation_name)
		
	node.set(max_property, Save.data[max_save_key])

func _ready() -> void:
	if not node or max_property == "": return

	Save.connect("save_data_updated", _on_save_data_updated)	
	
	if Save.data.has(max_save_key):
		node.set(max_property, Save.data[max_save_key])
	else:
		Save.data[max_save_key] = node.get(max_property)
		
	if set_property_to_max_in_ready and property != "":
		node.set(property, node.get(max_property))

#func _process(_delta: float) -> void: # For debugging
	#if update_node and update_property != "":
		#print(update_node.get(update_property))			

			
