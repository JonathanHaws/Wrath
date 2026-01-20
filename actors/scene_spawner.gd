## Used for particles, projectiles, and other dynamically spawned scenes
## Use top level for scene transforms to avoid them following parents 
extends Node
@export var scenes: Array[PackedScene]
@export var scene_to_spawn: int = 0 ## Specifies which scene to spawn 
@export var random_scene: bool = false ## Overrides 'scene_to_spawn'
@export var add_to_scene_root: bool = false ## Makes spawned scene a child of the scene root instead of this node. Useful when particles want to spawn other particles) Still starts with this nodes initial transform though
func get_scene_to_spawn() -> PackedScene:
	if scenes.size() == 0: return null 
	if random_scene: return scenes[randi() % scenes.size()]
	if scene_to_spawn >= 0 and scene_to_spawn < scenes.size():
		return scenes[scene_to_spawn]
	if scenes.size() == 1: # fallback if only one scene exists
		return scenes[0]
	return null 

@export_group("Transform 3D") 
@export var target: Node3D = null ## Specifies a target to orient towards with spawned scenes initial transform
@export var projectile_speed: float = 10.0
@export var projectile_gravity: float = 0.0	
func get_orientation_towards_position_3d(target_position: Vector3, position: Vector3) -> Basis:
	var to_target = target_position - position
	var distance = to_target.length()
	var time = distance / projectile_speed
	var target_velocity: Vector3
	
	if projectile_gravity > 0: # arc
		target_velocity = to_target / time
		target_velocity.y += 0.5 * projectile_gravity * time
	else: # straight
		target_velocity = to_target / time
	
	return Basis.looking_at(target_velocity.normalized(), Vector3.UP)

func spawn_towards_target(scene_count: int = 1, delay: float = 0.0) -> void:
	if target == null: return  
	#print('aiming targeted')
	for i in range(scene_count):
		var orientation = get_orientation_towards_position_3d(target.global_position, self.global_position)
		var transform = Transform3D(orientation, self.global_position)
		
		var scene = spawn()
		scene.global_transform = transform
		#if delay > 0: await get_tree().create_timer(delay).timeout

func spawn_along_curve(curve_group: String, scene_count: int = 1, delay: float = 0) -> void:
	var path: Path3D = null
	var curve: Curve3D = null
	for n in get_tree().get_nodes_in_group(curve_group):
		if n is Path3D and n.curve != null:
			path = n
			curve = n.curve
			break
	if path == null or curve == null: return  

	var percent_interval = float(1.0 / scene_count)
	for i in range(scene_count):
		var local_pos = curve.sample_baked((percent_interval * i) * curve.get_baked_length())
		var world_pos = path.to_global(local_pos)
		var orientation = get_orientation_towards_position_3d(world_pos, self.global_position)
		var transform = Transform3D(orientation, self.global_position)
		
		#var euler_rad = transform.basis.get_euler() # For debugging
		#var euler_deg = Vector3(# Vector3 in radians
			#rad_to_deg(euler_rad.x),
			#rad_to_deg(euler_rad.y),
			#rad_to_deg(euler_rad.z))
		#print(path.name, " ", (percent_interval * i), " ", euler_deg) 
		
		var scene = spawn()
		scene.global_transform = transform
		
		#if delay > 0: await get_tree().create_timer(delay).timeout

			
func spawn() -> Node:
	var scene_to_instantiate = get_scene_to_spawn()
	if scene_to_instantiate == null: return
	var scene = scene_to_instantiate.instantiate()
	
	if add_to_scene_root:
		var root = get_tree().get_current_scene()
		if root: root.add_child(scene)	
		if scene is Node3D: scene.global_transform = self.global_transform
	else:
		add_child(scene)	
	
	#if particles is Node3D and particles.material_override: #for making shader unique for every particle might be a bug
		#particles.material_override = particles.material_override.duplicate()
		
	return scene
