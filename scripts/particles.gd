extends Node
@export var particle_scenes: Array[PackedScene]
var owner_node: Node = null

func _ready() -> void:
	owner_node = self
		
func spawn(particle = 0, position_or_parent = null) -> void:

	var particle_scene = null
	
	if particle is int and particle >= 0 and particle < particle_scenes.size():
		particle_scene = particle_scenes[particle]

	elif particle is PackedScene:
		particle_scene = particle
	
	if particle_scene == null: return
	
	var particles = particle_scene.instantiate()
	if position_or_parent is Vector3:
		get_parent().add_child(particles)
		particles.global_transform.origin = position_or_parent
	
	else:
		if owner_node == null: return
		
		if particles is Node3D and particles.material_override:
			particles.material_override = particles.material_override.duplicate()
		
		#particles.global_transform = owner_node.global_transform
		
		owner_node.add_child(particles)
