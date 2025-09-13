# Used for particles and projectiles
extends Node3D
@export var scenes: Array[PackedScene]
@export var copy_transform_node: Node3D = null
@export var parent_node: Node = null
	
@export_group("Homing")
@export var homing_target: Node3D = null
@export var projectile_speed: float = 10.0
@export var projectile_gravity: float = 0.0	
	
func home_towards_target() -> void:
	
	if not homing_target: return
	
	var target_velocity: Vector3 = Vector3.ZERO
	
	var to_target = homing_target.global_position - global_position
	var distance = to_target.length()
	if not distance > 0.001: return
	var time = distance / projectile_speed

	if projectile_gravity > 0: # arc
		target_velocity = to_target / time
		target_velocity.y += 0.5 * projectile_gravity * time
	else: # straight
		target_velocity = to_target / time	
	
	if target_velocity.length() > 0.001:
		look_at(global_position + target_velocity.normalized(), Vector3.UP)
	
func spawn(particle = 0, position_or_parent = null) -> void:

	home_towards_target()

	var particle_scene = null
	if particle == null and scenes.size() == 1: # Default to only particle scene if none is specified
		particle_scene = scenes[0]
	if particle is int and particle >= 0 and particle < scenes.size():
		particle_scene = scenes[particle]
	elif particle is PackedScene:
		particle_scene = particle
	if particle_scene == null: return
	
	var particles = particle_scene.instantiate()
	
	if parent_node == null:
		get_tree().get_current_scene().add_child(particles)
	else:
		parent_node.add_child(particles)

	if position_or_parent is Vector3:
		particles.global_transform.origin = position_or_parent
		
	if copy_transform_node:
		particles.global_transform = copy_transform_node.global_transform
		
	#if particles is Node3D and particles.material_override: #for making shader unique for every particle might be a bug
		#particles.material_override = particles.material_override.duplicate()
		
