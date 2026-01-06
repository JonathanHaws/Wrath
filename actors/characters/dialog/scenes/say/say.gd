extends AnimationPlayer
@export var info: String = ""
@export var label: Label

func _ready():
	label.text = info

func exit_area(): 
	if not current_animation == "exited":
		queue("exited")

func _process(_delta):
	if Input.is_action_just_pressed("interact"): 
		if not current_animation == "exited":
			queue("exited")
			tree_exited.connect(get_parent()._spawn_next_dialog)
