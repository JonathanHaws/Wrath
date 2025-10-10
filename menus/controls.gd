extends Node
const JOYPAD_BUTTON_NAMES := {
	0: "PAD A",
	1: "PAD B",
	2: "PAD X",
	3: "PAD Y",
	4: "LB",
	5: "RB",
	6: "Select",
	7: "Start",
	8: "LStick",
	9: "RStick",
	10: "DPad Up",
	11: "DPad Down",
	12: "DPad Left",
	13: "DPad Right"
}

func get_action_bindings(action: String) -> String:
	var keys := []
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			var code = ev.keycode if ev.keycode != 0 else ev.physical_keycode
			keys.append(OS.get_keycode_string(code))
		elif ev is InputEventJoypadButton:
			keys.append(JOYPAD_BUTTON_NAMES.get(ev.button_index, str(ev.button_index)))
		elif ev is InputEventMouseButton:
			keys.append("Mouse " + str(ev.button_index))
	return ", ".join(keys) if keys.size() > 0 else "(Unassigned)"


# Hidden Cursor
var idle_time_seconds := 0.0
var idle_timeout_seconds := 2.0
var last_time 
func hide_mouse() -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func show_mouse() -> void:
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
