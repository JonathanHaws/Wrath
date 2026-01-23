extends AnimationPlayer
@export var info: String = ""
@export var label: Label

func _ready():
	label.text = info

func exit_area() -> void:
	queue("exited")

func spawn_next_dialog() -> void:
	get_parent()._spawn(true)
	
func _process(_delta):
	if Input.is_action_just_pressed("interact"): 
		queue("exited")
					
