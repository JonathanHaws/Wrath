# Used for particles and projectiles
extends Node
@export var particle_scenes: Array[PackedScene]
@export var copy_transform_node: Node3D = null
@export var parent_node: Node = null
	
func spawn(particle = 0, position_or_parent = null) -> void:

	var particle_scene = null
	if particle == null and particle_scenes.size() == 1: # Default to only particle scene if none is specified
		particle_scene = particle_scenes[0]
	if particle is int and particle >= 0 and particle < particle_scenes.size():
		particle_scene = particle_scenes[particle]
	elif particle is PackedScene:
		particle_scene = particle
	if particle_scene == null: return
	
	var particles = particle_scene.instantiate()
	
	if parent_node == null:
		get_tree().root.add_child(particles)
	else:
		parent_node.add_child(particles)

	
	
	if position_or_parent is Vector3:
		particles.global_transform.origin = position_or_parent
		
	if copy_transform_node:
		particles.global_transform = copy_transform_node.global_transform
		
	#if particles is Node3D and particles.material_override: for making shader unique for every particle might be a bug
		#particles.material_override = particles.material_override.duplicate()
		
