extends AnimationPlayer
@export var info: String = ""
@export var auto_play: bool = true
@export var auto_play_string: String = "entered"
@export var label: Label

func _ready():

	label.text = info
		
	if auto_play:
		play(auto_play_string)

func _process(_delta):

	var parent = get_parent()
	if parent and "in_range" in parent:
		if not parent.in_range or Input.is_action_just_pressed("interact"):
			queue("exited")
