extends Node # slowmotion / freeze frames

func impact(duration: float, speed: float = 0.0) -> void:
	Engine.time_scale = speed
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1
