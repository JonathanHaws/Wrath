extends AnimationPlayer
@export var info: Array = []

func _ready():
	if info.size() > 0:
		$Control/Label.text = info[0]

func _process(_delta):
	var parent = get_parent()
	if parent and "in_range" in parent:
		if not parent.in_range or Input.is_action_just_pressed("talk"):
			queue("exited")
