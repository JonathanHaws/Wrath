extends Node # slowmotion / freeze frames

func impact(duration: float, speed: float = 0.0) -> void:
	if speed == 0.0:
		# For some reason collision breakes with time_scale set to 0. Using pause instead
		get_tree().paused = true 
	else:
		Engine.time_scale = speed
	await get_tree().create_timer(duration, true, false, true).timeout
	if speed == 0.0:
		get_tree().paused = false
	else:
		Engine.time_scale = 1.0
