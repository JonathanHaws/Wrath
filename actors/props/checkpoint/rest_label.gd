extends Label

@export var action_name: String = "Rest"

const JOYPAD_BUTTON_NAMES := {
	0: "A",
	1: "B",
	2: "X",
	3: "Y",
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

func _ready():
	var keys := []
	for ev in InputMap.action_get_events(action_name):
		if ev is InputEventKey:
			var code = ev.keycode if ev.keycode != 0 else ev.physical_keycode
			keys.append(OS.get_keycode_string(code))
		elif ev is InputEventJoypadButton:
			keys.append(JOYPAD_BUTTON_NAMES.get(ev.button_index, str(ev.button_index)))
	text += ", ".join(keys)
