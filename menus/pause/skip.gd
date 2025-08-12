extends Button
@export var CINEMATIC_GROUP: String
@export var PAUSE_TOGGLE_GROUP: String
var cinematic_node: Node
var pause_toggle_node: Node

func _skip_cinematic() -> void:
	if pause_toggle_node: pause_toggle_node.toggle(false)
	if cinematic_node: cinematic_node._skip_cinematic()

func _ready() -> void:
	var cinematic_list = get_tree().get_nodes_in_group(CINEMATIC_GROUP)
	if cinematic_list.size() > 0:
		cinematic_node = cinematic_list[0]
	var pause_toggle_list = get_tree().get_nodes_in_group(PAUSE_TOGGLE_GROUP)
	if pause_toggle_list.size() > 0:
		pause_toggle_node = pause_toggle_list[0]
	
	pressed.connect(_skip_cinematic)

func _process(_delta: float) -> void:
	if cinematic_node and cinematic_node.ANIM.is_playing():
		visible = true
	else:
		visible = false
	
	
	
