extends Node3D

func _ready():
	await get_tree().process_frame
	if not is_instance_valid(self): return
	
	global_transform = Transform3D(Basis(), global_position)
	 
