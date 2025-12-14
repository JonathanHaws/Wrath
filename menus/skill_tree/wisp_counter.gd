extends Label

func _ready():
	if visible:
		text = str(int(Save.data.get("wisp", 0)))

func _process(_d):
	if visible:
		text = str(int(Save.data.get("wisp", 0)))
