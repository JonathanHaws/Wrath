extends Button

func _ready() -> void:
	connect("pressed", _on_quit_pressed)

func _on_quit_pressed() -> void:
	get_tree().quit()
