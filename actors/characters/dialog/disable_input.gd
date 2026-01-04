extends Node
var _saved_map := {}

func toggle_action(actions, enable: bool) -> void:
	if typeof(actions) == TYPE_STRING:
		actions = [actions]

	for action in actions:
		if enable:
			if action in _saved_map:
				InputMap.action_erase_events(action)
				for ev in _saved_map[action]:
					InputMap.action_add_event(action, ev)
				_saved_map.erase(action)
		else:
			if not _saved_map.has(action):
				_saved_map[action] = InputMap.action_get_events(action)
				InputMap.action_erase_events(action)
