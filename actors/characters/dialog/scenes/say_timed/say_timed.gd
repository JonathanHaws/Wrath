extends AnimationPlayer
@export var info: Dictionary = {}
@export var label: Label
var timer: Timer

func _ready():
	
	if info.has("say"):
		label.text = info["say"]
	
	timer = Timer.new()
	
	if info.has("for"):
		timer.wait_time = info["for"]
	
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer) 
	timer.start()

func _on_timer_timeout() -> void:
	queue("time_complete")

	if info.has("sequence"): get_parent()._spawn()
