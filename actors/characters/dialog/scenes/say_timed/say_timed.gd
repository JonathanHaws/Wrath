extends AnimationPlayer
@export var info: Array = []
@export var label: Label
var timer: Timer

func _ready():
	label.text = info[0]
	timer = Timer.new()
	timer.wait_time = info[1]
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer) 
	timer.start()

func _on_timer_timeout() -> void:
	queue("time_complete")
	if info.size() >= 3 and info[2] == 1: # chain together
		get_parent()._spawn()
