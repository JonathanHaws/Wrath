extends AnimationPlayer
var info: Array = []

func _ready():
	$Label.text = info[0] if info.size() > 0 else ""

func _process(_delta):
	if not get_parent().in_range or Input.is_action_just_pressed("talk"): 
		queue("exited")
		return
