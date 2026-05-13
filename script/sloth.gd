extends Path3D
@onready var BODY = $PathFollow3D/Body

func _physics_process(_delta: float) -> void:
	BODY.global_transform = $PathFollow3D.global_transform
