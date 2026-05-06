extends Node3D 
## Uses a file instead of packed scene to avoid circular dependencies with tscn files.
## Still updates references automatically though if reogranizing folders
@export_file("*.tscn") var DESTINATION_SCENE: String 
@export var DESTINATION_NODE_NAME: String ## The unique node name of the door to teleport to
@onready var AREA: Area3D = $Area3D
@onready var START: Node3D = $Start

@export_group("Enter Animation") 
@export var ANIM: AnimationPlayer
@export var ANIM_NAME: String = "DOOR"

@export_group("Locking") 
@export var SAVE_LOCKED: bool = true
@export var LOCKED: bool = false

@export_group("Player") 
@export var PLAYER_BODY_GROUP = "player" ## Only a body that belongs to this group can trigger the door
@export var PLAYER_ANIM_GROUP: String = "player_anim"  ## (Optional) If you want a door animation to be triggered in player  
@export var PLAYER_ANIM_NAME: String = "DOOR" ## The name of the animation to play 
## Potential Todo: add a boolean that will teleport the players body to proper position for a synchronized animation

func _load_new_scene() -> void:
	Save.data["door_node_name"] = DESTINATION_NODE_NAME
	Save.save_game()
	
	if DESTINATION_SCENE != "":
		#var scene_path = ProjectSettings.globalize_path(DESTINATION_SCENE)
		#print("changing scene to: ", scene_path.get_file().get_basename())
		
		get_tree().change_scene_to_file(DESTINATION_SCENE)
	else:
		load_player_position()

func load_player_position() -> void:
	if not Save.data.has("door_node_name"): return
	var door_name = Save.data["door_node_name"]
	var door_node = get_tree().root.find_child(door_name, true, false)
	Save.data.erase("door_node_name")
	#print(door_name)
	#print(door_node.name)

	if door_node and door_node.START:
		#print('teleporting player')
		var player = get_tree().get_first_node_in_group(PLAYER_BODY_GROUP)
		player.global_transform = door_node.START.global_transform
		player.get_node("Mesh").transform = Transform3D.IDENTITY
		player.get_node("SpringArm3D").global_basis = door_node.START.global_basis
		player.CAMERA.global_transform = player.CAMERA.TARGET_NODE.global_transform
		player.FADE_IN_ANIM.play("DOOR_FADE_IN")

func _on_area_body_entered(body: Node) -> void:
	if LOCKED: return
	if PLAYER_BODY_GROUP != "" and not body.is_in_group(PLAYER_BODY_GROUP): return
	if ANIM and ANIM_NAME != "": ANIM.play(ANIM_NAME)
	for node in get_tree().get_nodes_in_group(PLAYER_ANIM_GROUP):
		if node is AnimationPlayer and node.has_animation(PLAYER_ANIM_NAME):
			node.play(PLAYER_ANIM_NAME)

func _exit_tree() -> void:
	if SAVE_LOCKED:
		Save.data[Save.get_unique_key(self,"Locked")] = LOCKED
		Save.save_game()

func _ready() -> void:
	AREA.connect("body_entered", Callable(self, "_on_area_body_entered"))
	
	if SAVE_LOCKED and Save.data.has(Save.get_unique_key(self,"Locked")):
		LOCKED = Save.data[Save.get_unique_key(self,"Locked")]
		
	if Save.data.has("door_node_name") and name == Save.data["door_node_name"]:
		load_player_position()
	
