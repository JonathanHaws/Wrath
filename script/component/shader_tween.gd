extends Node
@export var groups: Array[String] = ["target_mesh1"] ## The groups of meshes this tween will act upon. 
@export var textures: Array[Texture2D] = []	

func set_texture(
	texture_index: int = 0,
	parameter_name: String = "albedo_texture"
) -> void:
	
	if groups.is_empty() or texture_index < 0 or texture_index >= textures.size(): return
	for i in range(groups.size()): groups[i] = str(groups[i])

	var texture: Texture2D = textures[texture_index]

	for group_name in groups:
		var nodes = get_tree().get_nodes_in_group(group_name)
		for node in nodes:
			if not node: continue
			var mat: ShaderMaterial = null
			if node is MeshInstance3D:
				mat = node.get_active_material(0) as ShaderMaterial
			elif node is Sprite2D:
				mat = node.material as ShaderMaterial
			if not mat: continue

			mat.set_shader_parameter(parameter_name, texture)

func tween(
	property_name: String = "dissolve_amount",
	target_value: float = 1.0,
	time_sec: float = 1.0
) -> void:
	if groups.is_empty(): return
	for i in range(groups.size()): groups[i] = str(groups[i])

	for group_name in groups:
		var nodes = get_tree().get_nodes_in_group(group_name)
		for node in nodes:
			if not node: continue
			var mat: ShaderMaterial = null
			if node is MeshInstance3D:
				mat = node.get_active_material(0) as ShaderMaterial
			elif node is Sprite2D:
				mat = node.material as ShaderMaterial
			if not mat: continue

			var start_value = mat.get_shader_parameter(property_name)
			var tween_shader = create_tween()
			tween_shader.tween_method(
				func(value): mat.set_shader_parameter(property_name, value),
				start_value, target_value, time_sec
			)
