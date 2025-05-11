
extends OptionButton

func _ready() -> void:
	connect("item_selected", _on_window_mode_changed)

func _on_window_mode_changed(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
