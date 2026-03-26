extends Node3D
@export var target: Node3D
@export var speed: float = 50

func _physics_process(delta):
	global_position = global_position.move_toward(target.global_position, speed * delta)
