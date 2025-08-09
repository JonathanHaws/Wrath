extends Area3D
@export var GROUP = "player"
@export var CHECKPOINT_NODE: Node3D
@export var CHECKPOINT_SCENE_PATH: String
@export var ANIM: AnimationPlayer

func get_starting_transform() -> Transform3D:
	var checkpoint_transform = global_transform
	var euler_angles = checkpoint_transform.basis.get_euler()
	euler_angles.x = 0
	euler_angles.z = 0
	checkpoint_transform.basis = Basis().rotated(Vector3.UP, euler_angles.y)
	return checkpoint_transform

func _on_body_entered(body: Node) -> void:
	if GROUP != "" and not body.is_in_group(GROUP): return

	if Save.data.has("checkpoint_node_path") and get_path() == NodePath(Save.data["checkpoint_node_path"]) and \
	   Save.data.has("checkpoint_scene_path") and Save.data["checkpoint_scene_path"] == get_tree().current_scene.scene_file_path:
		return  # Skip if already acquired
	
	if "HEALTH" in body and "MAX_HEALTH" in body:
		#print('replenishing')
		if body.HEALTH < body.MAX_HEALTH:
			body.HEALTH = body.MAX_HEALTH
	
	ANIM.play("ACQUIRED")
	Save.data["checkpoint_node_path"] = get_path()
	Save.data["checkpoint_scene_path"] = get_tree().current_scene.scene_file_path
	Save.save_game()
