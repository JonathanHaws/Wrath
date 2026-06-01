extends Node3D ## Current bug: Must be older then player in scene tree or start wont be ready to position the player

## Uses a file instead of packed scene to avoid circular dependencies with tscn files.
## Still updates references automatically though if reogranizing folders
@export_file("*.tscn") var DESTINATION_SCENE: String 
@export var DESTINATION_NODE_NAME: String ## The unique node name of the door to teleport to
@export var AREA: Area3D = get_node_or_null("Area3D")
@export var START: Node3D = get_node_or_null("Start")

@export_group("Enter Animation") 
@export var ANIM: AnimationPlayer
@export var ANIM_NAME: String = "DOOR"

@export_group("Locking") 
@export var SAVE_LOCKED: bool = false
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

func find_door_node_or_null(door_name: String) -> Node:
	for node in get_tree().root.find_children(door_name, "", true, false):
		if "START" in node: return node # avoid name collision with non door nodes "Exit" for example
		# add more validating checks if needed
	return null

func load_player_position() -> void:
	if not Save.data.has("door_node_name"): return
	var door_name = Save.data["door_node_name"]
	var door_node = find_door_node_or_null(door_name)
	Save.data.erase("door_node_name")
	#print(door_name)
	#print(door_node.name)

	if door_node and door_node:
		#print('teleporting player')
		var player = get_tree().get_first_node_in_group(PLAYER_BODY_GROUP)

		player.global_transform = door_node.START.global_transform
		player.get_node("Mesh").transform = Transform3D.IDENTITY
		
		player.get_node("SpringArm3D").global_basis = door_node.START.global_basis
		player.CAMERA.last_spring_arm_orientation = door_node.START.global_basis
		
		player.CAMERA.transform = Transform3D.IDENTITY
		player.CAMERA.global_transform = player.CAMERA.TARGET_NODE.global_transform

		player.FADE_IN_ANIM.play("DOOR_FADE_IN")
		
		# # For debugging... Checks if spring orientation retains door start orientation
		#await get_tree().physics_frame
		#await get_tree().process_frame
		#print("Camera orientation matches door start orientation: ", player.get_node("SpringArm3D").global_basis.is_equal_approx(door_node.START.global_basis))

		


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
	
