extends Node
@export var interval: float = 5.0
var time_passed := 0.0

func _on_timer_timeout():
	Save.save_game()

func _ready():
	var timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _process(delta):
	time_passed += delta
	if Save.data.has("play_time"):
		Save.data["play_time"] += delta
	else:
		Save.data["play_time"] = delta
