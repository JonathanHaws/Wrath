extends Node

func tween(
	groups:= ["target_mesh1"],
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
