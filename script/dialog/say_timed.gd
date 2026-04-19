extends AnimationPlayer
@export var dialog: Node ## Auto assigned from parent spawner
@export var info: Dictionary = {} ## Auto assigned from parent spawner
@export var label: Label
var timer: Timer

func _ready():
	
	for group_name in get_groups(): get_node("Control/Label").add_to_group(group_name) #Copy 
	
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

	var next_entry: Dictionary = dialog.get_dictionary_for_value(dialog.index + 1, 0)
	if next_entry and !next_entry.has("branch"):
		dialog.goto(dialog.index + 1)
		dialog.spawn()
		
