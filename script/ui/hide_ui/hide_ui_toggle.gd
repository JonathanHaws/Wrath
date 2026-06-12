extends OptionButton

func _ready() -> void:
	clear()
	add_item("SHOW UI")
	add_item("HIDE UI")
	selected = 1 if Config.HIDE_UI else 0
	item_selected.connect(_on_item_selected)

func _on_item_selected(index: int) -> void:
	Config.set_hide_ui(index == 1)
