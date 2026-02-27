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
	13: "DPad Right",
	}
func get_event_from_string(s: String) -> InputEvent:
	var ev: InputEvent = null
	if s.begins_with("Mouse "):
		ev = InputEventMouseButton.new()
		ev.button_index = int(s.split(" ")[1])
	elif JOYPAD_BUTTON_NAMES.values().has(s):
		ev = InputEventJoypadButton.new()
		ev.button_index = JOYPAD_BUTTON_NAMES.find_key(s)
	else:
		var code: int = OS.find_keycode_from_string(s)
		if code != 0:
			ev = InputEventKey.new()
			ev.keycode = code
	return ev
func get_string_from_event(ev: InputEvent) -> String:
	if ev is InputEventKey:
		var code = ev.keycode if ev.keycode != 0 else ev.physical_keycode
		return OS.get_keycode_string(code)
	elif ev is InputEventJoypadButton:
		return JOYPAD_BUTTON_NAMES.get(ev.button_index, str(ev.button_index))
	elif ev is InputEventMouseButton:
		return "Mouse " + str(ev.button_index)
	return "(Unknown)"
func get_string_from_action(action: String) -> String:
	var keys := []
	for ev in InputMap.action_get_events(action):
		keys.append(get_string_from_event(ev))
	return ", ".join(keys) if keys.size() > 0 else "(Unassigned)"
func get_events_from_string(s: String) -> Array[InputEvent]:
	var events: Array[InputEvent] = []
	for part in s.split(","):
		var ev = get_event_from_string(part.strip_edges())
		if ev: events.append(ev)
	return events
func load_action_setting(action: String) -> void:
	var saved_string: String = Config.load_setting("controls", action, "default")
	if saved_string != "default":
		InputMap.action_erase_events(action)
		var events = Controls.get_events_from_string(saved_string)
		for ev in events: InputMap.action_add_event(action, ev)
func save_action_setting(action: String) -> void:
	# Convert current InputMap state to a string and save
	var current_binds = Controls.get_string_from_action(action)
	Config.save_setting("controls", action, current_binds)
func load_action_settings() -> void:
	var actions = [
		"lock_on", 
		"keyboard_forward", 
		"keyboard_back", 
		"keyboard_left", 
		"keyboard_right", 
		"jump", 
		"attack", 
		"block", 
		"shoot", 
		"interact", 
		"heal", 
		"dash", 
		"rest", 
		"toggle_skill_tree"
		]
	for action in actions: load_action_setting(action)

# For disabling input... 
func play_input_anim(animation_name: String, group_name: String = "input_anim") -> void:
	
	#print(animation_name)
	for p in get_tree().get_nodes_in_group(group_name):
		if p is AnimationPlayer:
			p.play(animation_name, 0)
			p.advance(p.current_animation_length)

# Hidden Cursor
var last_position_visible :Vector2 = Vector2.ZERO
var mouse_tolerance := 10.0  # pixels
var idle_time_seconds := 0.0
var idle_timeout_seconds := 2.0

func _ready():
	await get_tree().process_frame
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	idle_time_seconds = idle_timeout_seconds + 1

	load_action_settings()

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: return
	if event is InputEventMouseMotion:
		var current_pos = get_viewport().get_mouse_position()
		if last_position_visible.distance_to(current_pos) > mouse_tolerance:
			last_position_visible = get_viewport().get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta):
	#print(Input.get_mouse_mode())
	#print(idle_time_seconds)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		idle_time_seconds += _delta
		if idle_time_seconds >= idle_timeout_seconds:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			idle_time_seconds = 0
