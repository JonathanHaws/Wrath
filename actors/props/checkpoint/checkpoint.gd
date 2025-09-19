extends Area3D
@export var GROUP = "player"
@export var HITSHAPE_GROUP = "player_hitshape"
@export var CHECKPOINT_NODE: Node3D
@export var CHECKPOINT_SCENE_PATH: String
@export var REST_ANIM: AnimationPlayer
@export var AQUIRED_ANIM: AnimationPlayer
@export var ENTER_EXIT_ANIM: AnimationPlayer
@export var REST_ACTIONS: Array[String] = ["attack"]
@export var RESPAWN_DATA_KEY: String = "respawn_data"
var player_inside: bool = false

func load_checkpoint(player: Node3D) -> void:
	var checkpoint_transform = global_transform
	var euler_angles = checkpoint_transform.basis.get_euler()
	euler_angles.x = 0
	euler_angles.z = 0
	checkpoint_transform.basis = Basis().rotated(Vector3.UP, euler_angles.y)
	
	player.global_transform = checkpoint_transform
	
	#if Save.data.has(RESPAWN_DATA_KEY) and Save.data[RESPAWN_DATA_KEY] != {}: # Force rest if still have respawn data when it should never be the case
		#call_deferred("_rest")

func _rest() -> void:
	for hitshape in get_tree().get_nodes_in_group(HITSHAPE_GROUP):
		if "HEALTH" in hitshape and "MAX_HEALTH" in hitshape:
			hitshape.HEALTH = hitshape.MAX_HEALTH
	if Save.data.has("respawn_data"): Save.data["respawn_data"].clear()
	Save.save_game()
	get_tree().reload_current_scene()

func _play_aquired() -> void:
	
	if Save.data.has("checkpoint_node_path") and get_path() == NodePath(Save.data["checkpoint_node_path"]) and \
		Save.data.has("checkpoint_scene_path") and Save.data["checkpoint_scene_path"] == get_tree().current_scene.scene_file_path:
		return  
					
	Save.data["checkpoint_node_path"] = get_path()
	Save.data["checkpoint_scene_path"] = get_tree().current_scene.scene_file_path
	
	AQUIRED_ANIM.play("AQUIRED")

func _on_body_entered(body: Node) -> void:
	if GROUP != "" and not body.is_in_group(GROUP): return
	player_inside = true
	ENTER_EXIT_ANIM.queue("ENTER")
	
	# AQUIRE CHECKPOINT IF NOT ALREADY HAVE BUT DONT HEAL HEALTH
	if Save.data.has("checkpoint_node_path") and get_path() == NodePath(Save.data["checkpoint_node_path"]): 
		if Save.data.has("checkpoint_scene_path") and Save.data["checkpoint_scene_path"] == get_tree().current_scene.scene_file_path:
			return #ALREADY AQUIRED
		
	Save.data["checkpoint_node_path"] = get_path()
	Save.data["checkpoint_scene_path"] = get_tree().current_scene.scene_file_path
	AQUIRED_ANIM.play("AQUIRED")
	
func _on_body_exited(body: Node) -> void:
	if GROUP != "" and not body.is_in_group(GROUP): return
	player_inside = false
	ENTER_EXIT_ANIM.queue("EXIT")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if player_inside:
		for action in REST_ACTIONS:
			if Input.is_action_just_pressed(action):
				if not REST_ANIM.is_playing() and not REST_ANIM.current_animation == "REST": REST_ANIM.play("REST")
