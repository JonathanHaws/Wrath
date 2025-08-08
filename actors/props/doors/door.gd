extends Node3D
@export var AREA: Area3D
@export var ANIM: AnimationPlayer
@export var ANIM_NAME: String = "DOOR"
@export var START: Node3D
@export var DESTINATION_NODE_NAME: String 
## Uses a file instead of packed scene to avoid circular dependencies with tscn files.
## Still updates references automatically though if reogranizing folders in godot
@export_file("*.tscn") var DESTINATION_SCENE: String 

@export_group("Player Groups")
## Only a body that belongs to this group can trigger the door
@export var PLAYER_BODY_GROUP = "player"
## (Optional) If you want a door animation to be triggered in player 
@export var PLAYER_ANIM_GROUP: String = "player_anim"
## The name of the animation to play 
@export var PLAYER_ANIM_NAME: String = "DOOR"
## Potential Todo: add a boolean that will teleport the players body to proper position for a synchronized animation

func _load_new_scene() -> void:
	Save.data["door_node_name"] = DESTINATION_NODE_NAME
	Save.save_game()
	
	if DESTINATION_SCENE != "":
		get_tree().change_scene_to_file(DESTINATION_SCENE)

func _on_area_body_entered(body: Node) -> void:
	if PLAYER_BODY_GROUP != "" and not body.is_in_group(PLAYER_BODY_GROUP): return
	if not DESTINATION_SCENE: return
	if ANIM and ANIM_NAME != "": ANIM.play(ANIM_NAME)
	for node in get_tree().get_nodes_in_group(PLAYER_ANIM_GROUP):
		if node is AnimationPlayer and node.has_animation(PLAYER_ANIM_NAME):
			node.play(PLAYER_ANIM_NAME)

func _ready() -> void:
	AREA.connect("body_entered", Callable(self, "_on_area_body_entered"))
