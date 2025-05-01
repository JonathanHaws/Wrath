extends Node

func spawn(particle_position: Vector3, particle_scene: PackedScene) -> void:
	if particle_scene == null: return
	var particles = particle_scene.instantiate()
	get_parent().add_child(particles)
	particles.global_transform.origin = particle_position
