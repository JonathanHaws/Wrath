extends Node
@export var action_name: String
@export var display_name: String = ""
@export var label: Label
@export var add: Button
@export var remove: Button

var waiting_for_new := false
var last_pressed_event: InputEvent = null

func _update_label() -> void:
	#Config.save_setting("controls", action_name, Controls.get_action_bindings(action_name))
	label.text = display_name + " - " + Controls.get_action_bindings(action_name) + " "
	
func _reset_buttons() -> void:
	waiting_for_new = false
	add.text = "+"
	remove.text = "-"

func _ready() -> void:
	
	#var events = Config.load_setting("controls", action_name, InputMap.action_get_events(action_name))
	
	#print(action_name, " ", events)
	
	_update_label()
	add.pressed.connect(_on_add_pressed)
	remove.pressed.connect(_on_remove_pressed)

func _on_add_pressed() -> void:
	waiting_for_new = true
	add.text = "Press key..."

func _on_remove_pressed() -> void:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		InputMap.action_erase_event(action_name, events[events.size() - 1])
		_update_label()
		_reset_buttons()
		
func _input(event: InputEvent) -> void:
	if waiting_for_new and event.is_pressed():
		InputMap.action_add_event(action_name, event)
		last_pressed_event = event
		waiting_for_new = false
		_update_label()
		_reset_buttons()
