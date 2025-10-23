extends Area3D
@export var GROUP = "player"
@export var HITSHAPE_GROUP = "player_hitshape"
@export var CHECKPOINT_NODE: Node3D
@export var CHECKPOINT_SCENE_PATH: String
@export var REST_ANIM: AnimationPlayer
@export var AQUIRED_ANIM: AnimationPlayer
@export var PROMPT_ANIM: AnimationPlayer ## Animation player for when player enters area they can potentially rest
@export var REST_ACTIONS: Array[String] = ["interact"]
var player_inside: bool = false
var enter_prompt_played: bool = false
@export_file("*.tscn") var skill_tree_file: String

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
	#get_tree().reload_current_scene()
	get_tree().change_scene_to_file(skill_tree_file)

func _play_aquired() -> void:
	
	if Save.data.has("checkpoint_node_path") and get_path() == NodePath(Save.data["checkpoint_node_path"]) and \
		Save.data.has("checkpoint_scene_path") and Save.data["checkpoint_scene_path"] == get_tree().current_scene.scene_file_path:
		return  
					
	Save.data["checkpoint_node_path"] = get_path()
	Save.data["checkpoint_scene_path"] = get_tree().current_scene.scene_file_path
	
	AQUIRED_ANIM.play("AQUIRED")

func _on_body_entered(body: Node) -> void:
	if GROUP != "" and not body.is_in_group(GROUP): return
	enter_prompt_played = true
	
	player_inside = true
	PROMPT_ANIM.queue("ENTER")
	
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
	if not enter_prompt_played: return
	PROMPT_ANIM.queue("EXIT")

func _ready() -> void:
	await get_tree().create_timer(.2).timeout # Makes it so that if player spawns in they dont get the prompt immeaditly... Only when they leave and hop back on...
	_connect_signals()

func _connect_signals() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if player_inside:
		for action in REST_ACTIONS:
			if Input.is_action_just_pressed(action):
				if not REST_ANIM.is_playing() and not REST_ANIM.current_animation == "REST": REST_ANIM.play("REST")
