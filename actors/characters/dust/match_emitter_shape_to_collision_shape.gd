extends Node3D
@export var particles: GPUParticles3D
@export var collision_shape: CollisionShape3D

func _process(_delta: float) -> void:
	if not particles or not collision_shape: return
	var shape = collision_shape.shape
