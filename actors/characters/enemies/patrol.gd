extends PathFollow3D

@export var speed: float = 5.0
@export var extend_after_end: bool = true


func _physics_process(delta: float) -> void:
	progress += speed * delta
