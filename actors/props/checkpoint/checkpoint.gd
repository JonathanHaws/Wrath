extends Area3D
@export var GROUP = "player"
@export var HITSHAPE_GROUP = "player_hitshape"
@export var CHECKPOINT_NODE: Node3D
@export var CHECKPOINT_SCENE_PATH: String
@export var ANIM: AnimationPlayer
@export var ENTER_EXIT_ANIM: AnimationPlayer
@export var REST_ACTIONS: Array[String] = ["attack"]
var player_inside: bool = false

func get_starting_transform() -> Transform3D:
	var checkpoint_transform = global_transform
	var euler_angles = checkpoint_transform.basis.get_euler()
	euler_angles.x = 0
	euler_angles.z = 0
	checkpoint_transform.basis = Basis().rotated(Vector3.UP, euler_angles.y)
	return checkpoint_transform

func _aquire() -> void:

	for hitshape in get_tree().get_nodes_in_group(HITSHAPE_GROUP):
		if "HEALTH" in hitshape and "MAX_HEALTH" in hitshape:
			hitshape.HEALTH = hitshape.MAX_HEALTH
			
	Save.data["checkpoint_node_path"] = get_path()
	Save.data["checkpoint_scene_path"] = get_tree().current_scene.scene_file_path
	
	if Save.data.has("respawn_data"): Save.data["respawn_data"].clear()

	Save.save_game()
	
	get_tree().reload_current_scene()

func _play_aquire() -> void:
	if ANIM.is_playing() and ANIM.current_animation == "ACQUIRED": return
	ANIM.play("ACQUIRED")


func _on_body_entered(body: Node) -> void:
	if GROUP != "" and not body.is_in_group(GROUP): return
	player_inside = true
	ENTER_EXIT_ANIM.queue("ENTER")

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
				_play_aquire()
