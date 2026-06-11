extends LookAtModifier3D

@export_range(0.0, 1.0) var target_influence := 1.0
@export var blend_speed := 5.0

func _process(delta: float) -> void:
	influence = lerp(
		influence,
		target_influence,
		1.0 - exp(-blend_speed * delta)
	)
