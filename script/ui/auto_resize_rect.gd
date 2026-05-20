extends ColorRect

@export var target: Control
@export var padding: Vector2 = Vector2(10, 10)

func _process(_delta):
	if target == null: return
	if !target.is_inside_tree(): return
	var rect := target.get_combined_minimum_size()


	size = rect + padding * 2.0
	position = target.position - padding
