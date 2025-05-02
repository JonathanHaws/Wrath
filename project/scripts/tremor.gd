extends Node
var noise := FastNoiseLite.new()
var shake_offset := Vector3.ZERO

func _on_body_entered(body) -> void:
	var camera = body.find_child("", true, false)
	
	get_children()
	if camera is Camera3D and camera.has_variable("shake"):
		camera.shake = 5.0 # or any value you want
