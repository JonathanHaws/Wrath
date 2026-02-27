extends Node
const JOYPAD_BUTTON_NAMES := {
	0: "PAD A",
	1: "PAD B",
	2: "PAD X",
	3: "PAD Y",
	4: "LB",
	5: "RB",
	6: "Select",
	7: "LS",
	8: "RS",
	9: "LB",
	10: "RB",
	11: "DP Up",
	12: "DP Down",
	13: "DP Left",
	14: "DP Right",
	}
const JOYPAD_AXIS_NAMES := {
	2: "LStick",
	3: "RStick",
	4: "LT",
	5: "RT",
	}
func get_event_from_string(s: String) -> InputEvent:
	var event: InputEvent = null
	if s.begins_with("Mouse "):
		event = InputEventMouseButton.new()
		event.button_index = int(s.split(" ")[1])
	elif JOYPAD_BUTTON_NAMES.values().has(s):
		event = InputEventJoypadButton.new()
		event.button_index = JOYPAD_BUTTON_NAMES.find_key(s)
	elif JOYPAD_AXIS_NAMES.values().has(s):
		event = InputEventJoypadMotion.new()
		event.axis = JOYPAD_AXIS_NAMES.find_key(s)
		event.axis_value = 1.0  # trigger press
	else:
		var code: int = OS.find_keycode_from_string(s)
		if code != 0:
			event = InputEventKey.new()
			event.keycode = code
	return event
func get_string_from_event(event: InputEvent) -> String:
	if event is InputEventKey:
		var code = event.keycode if event.keycode != 0 else event.physical_keycode
		return OS.get_keycode_string(code)
	elif event is InputEventJoypadButton:
		return JOYPAD_BUTTON_NAMES.get(event.button_index, str(event.button_index))
	elif event is InputEventJoypadMotion:
		return JOYPAD_AXIS_NAMES.get(event.axis, str(event.axis))
	elif event is InputEventMouseButton:
		return "Mouse " + str(event.button_index)
	return "(Unknown)"
func get_string_from_action(action: String) -> String:
	var keys := []
	for event in InputMap.action_get_events(action):
		keys.append(get_string_from_event(event))
	return ", ".join(keys) if keys.size() > 0 else "(Unassigned)"
func get_events_from_string(s: String) -> Array[InputEvent]:
	var events: Array[InputEvent] = []
	for part in s.split(","):
		var event = get_event_from_string(part.strip_edges())
		if event: events.append(event)
	return events
func load_action_setting(action: String) -> void:
	var saved_string: String = Config.load_setting("controls", action, "default")
	if saved_string != "default":
		InputMap.action_erase_events(action)
		var events = Controls.get_events_from_string(saved_string)
		for event in events: InputMap.action_add_event(action, event)
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
		"walk", 
		"attack", 
		"block", 
		"shoot", 
		"descend", 
		"interact", 
		"heal", 
		"dash", 
		"rest", 
		"interact", 
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
