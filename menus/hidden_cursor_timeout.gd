extends Node
var idle_time_seconds := 0.0
var idle_timeout_seconds := 2.0
var last_time 

func hide_mouse_for_dialogue() -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_mouse_for_dialogue() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _ready():
	await get_tree().process_frame
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	last_time = Time.get_ticks_msec() 
	idle_time_seconds = idle_timeout_seconds

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: return
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		idle_time_seconds = 0

func _process(_delta):

	#print(idle_time_seconds)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		if idle_time_seconds >= idle_timeout_seconds:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else: 
			var now = Time.get_ticks_msec() 
			idle_time_seconds += (now - last_time) / 1000.0
			last_time = now		
	else:
		idle_time_seconds = idle_timeout_seconds
