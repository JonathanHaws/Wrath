extends Node
@export var DEFAULT_SCENE: PackedScene = preload("res://scenes/ui/damage_numbers.tscn")

func show_symbol(pos: Vector3, offset_y: float = 0, damage_path: String = "", damage: float = 0, scene: PackedScene = DEFAULT_SCENE) -> void:
	var number = scene.instantiate()
	if damage_path != "": number.get_node(damage_path).text = str(int(damage))
	get_tree().current_scene.add_child(number)
	number.position = get_viewport().get_camera_3d().unproject_position(pos) - Vector2(0, offset_y)
