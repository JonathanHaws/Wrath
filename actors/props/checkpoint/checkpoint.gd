extends Area3D
@export var GROUP = "player"
@export var HITSHAPE_GROUP = "player_hitshape"
@export var CHECKPOINT_NODE: Node3D
@export var CHECKPOINT_SCENE_PATH: String
@export var REST_ANIM: AnimationPlayer
@export var AQUIRED_ANIM: AnimationPlayer
@export var ENTER_EXIT_ANIM: AnimationPlayer
@export var REST_ACTIONS: Array[String] = ["interact"]
@export var RESPAWN_DATA_KEY: String = "respawn_data"
var ignore_first_entry: bool = false # ignore first trigger if player spawns inside for prompt
var player_inside: bool = false

func load_checkpoint(player: Node3D) -> void:
	var checkpoint_transform = global_transform
	var euler_angles = checkpoint_transform.basis.get_euler()
	euler_angles.x = 0
	euler_angles.z = 0
	checkpoint_transform.basis = Basis().rotated(Vector3.UP, euler_angles.y)
	
	player.global_transform = checkpoint_transform

func _rest() -> void:
	if not Save.data.has("rests"): Save.data["rests"] = 1
	else: Save.data["rests"] += 1
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
	if ignore_first_entry: return
	
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
	if ignore_first_entry: ignore_first_entry = false; return # Dont play exit animation if enter animation was never played
	ENTER_EXIT_ANIM.queue("EXIT")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	for body in get_overlapping_bodies():
		if GROUP != "" and body.is_in_group(GROUP):
			ignore_first_entry = true
		
#
	#var player_health
	#var player_max_health
	#if Save.data.has(RESPAWN_DATA_KEY): player_health = Save.data[RESPAWN_DATA_KEY]["health"]
	#if Save.data.has("max_health"): player_max_health = Save.data["max_health"]
#
	#if player_health and player_max_health and player_health != player_max_health and ignore_first_entry:
		## Player spawned on this checkpoint node... but its health is not full... force rest
		#call_deferred("_rest")

func _process(_delta: float) -> void:
	if player_inside:
		for action in REST_ACTIONS:
			if Input.is_action_just_pressed(action):
				if not REST_ANIM.is_playing() and not REST_ANIM.current_animation == "REST": REST_ANIM.play("REST")
