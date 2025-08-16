extends HSlider

func _ready() -> void:
	value_changed.connect(_on_scale_changed)

func _on_scale_changed(val: float) -> void:
	get_viewport().canvas_transform = Transform2D().scaled(Vector2(val, val))
