## Used for particles, projectiles, and other dynamically spawned scenes
## Use top level for scene transforms to avoid them following parents 
extends Node
@export var scenes: Array[PackedScene]
@export var scene_to_spawn: int = 0 ## Specifies which scene to spawn 
@export var random_scene: bool = false ## Overrides 'scene_to_spawn'
@export var add_to_scene_root: bool = false ## Makes spawned scene a child of the scene root instead of this node. Useful when particles want to spawn other particles) Still starts with this nodes initial transform though

@export_group("Transform 3D") 
@export var path_3d: Path3D = null ## Specifies a 3D Curve to home to with spawned scenes inital transform
@export var homing_target: Node3D = null ## Specifies a target to orient towards with spawned scenes initial transform
@export var projectile_speed: float = 10.0
@export var projectile_gravity: float = 0.0	
func home_towards_position_3d(node: Node, target_pos: Vector3) -> void:
	var to_target = target_pos - node.global_position
	var distance = to_target.length()
	if distance <= 0.001: return
	
	var time = distance / projectile_speed
	var target_velocity: Vector3
	
	if projectile_gravity > 0: # arc
		target_velocity = to_target / time
		target_velocity.y += 0.5 * projectile_gravity * time
	else: # straight
		target_velocity = to_target / time
	
	if not node is Node3D: return 

	if target_velocity.length() > 0.001:
		node.look_at(node.global_position + target_velocity.normalized(), Vector3.UP)	
func home_towards_target(node: Node, target: Node3D = null) -> void:
	var actual_target: Node3D = null
	if target != null:
		actual_target = target
	elif homing_target != null:
		actual_target = homing_target
	if actual_target != null:
		home_towards_position_3d(node, actual_target.global_position)
		
func spawn(particle = 0, percent: float = 0) -> void:

	var scene_to_instantiate: PackedScene = null
	if particle != null and particle is PackedScene:
		scene_to_instantiate = particle
	elif random_scene and scenes.size() > 0:
		scene_to_instantiate = scenes[randi() % scenes.size()]
	elif scene_to_spawn >= 0 and scene_to_spawn < scenes.size():
		scene_to_instantiate = scenes[scene_to_spawn]
	elif scenes.size() == 1:
		scene_to_instantiate = scenes[0]
	var scene = scene_to_instantiate.instantiate()
	
	if add_to_scene_root:
		var root = get_tree().get_current_scene()
		if root: root.add_child(scene)	
	else:
		add_child(scene)	
	if scene is Node3D: scene.global_transform = self.global_transform
	
	if path_3d and path_3d.curve != null:

		var curve = path_3d.curve
		var length = curve.get_baked_length()
		var local_pos = curve.sample_baked(percent * length)
		var world_pos = path_3d.to_global(local_pos)
		home_towards_position_3d(scene, world_pos)
		
		print(path_3d.name, percent, scene.global_rotation_degrees) ## Verify all the functions are being called with right percentages deterministically
	else:
		home_towards_target(scene) 
	
	#if particles is Node3D and particles.material_override: #for making shader unique for every particle might be a bug
		#particles.material_override = particles.material_override.duplicate()
		
