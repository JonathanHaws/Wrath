extends Label

func _ready() -> void:
	text = str(int(Save.data.get("wisp", 0)))
