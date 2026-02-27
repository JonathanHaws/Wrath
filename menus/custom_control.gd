extends Node
@export var action_name: String
@export var display_name: String = ""
@export var container: Node = self
var waiting_for_new: bool = false
var last_pressed_event: InputEvent = null

func _input(event: InputEvent) -> void:
	if waiting_for_new and event.is_pressed():
		get_viewport().set_input_as_handled()
		InputMap.action_add_event(action_name, event)
		last_pressed_event = event
		waiting_for_new = false
		refresh_ui()

func create_delete_button(event: InputEvent) -> Button:
	var btn: Button = Button.new()  
	btn.text = Controls.event_to_string(event)
	btn.pressed.connect(func() -> void:
		InputMap.action_erase_event(action_name, event)   
		btn.queue_free()
		)
	return btn

func create_add_button() -> Button:
	var add_btn: Button = Button.new()
	add_btn.text = "+"
	add_btn.pressed.connect(func() -> void:
		waiting_for_new = true
		add_btn.text = "Press key..."		
		)
	return add_btn

func create_restore_button() -> Button:
	var restore_btn: Button = Button.new()
	restore_btn.text = "@"
	container.add_child(restore_btn)
	restore_btn.pressed.connect(func() -> void:
		for event in InputMap.action_get_events(action_name):
			InputMap.action_erase_event(action_name, event)
		for event in ProjectSettings.get_setting("input/" + action_name)["events"]:
			InputMap.action_add_event(action_name, event)
		refresh_ui()
	)
	return restore_btn

func refresh_ui():
	for child in container.get_children(): child.queue_free()
	
	var title: Label = Label.new()   
	title.text = display_name + " - "
	container.add_child(title)
	
	for event in InputMap.action_get_events(action_name):
		container.add_child(create_delete_button(event))	
	container.add_child(create_add_button())
	container.add_child(create_restore_button())

func _ready() -> void:
	refresh_ui()
	
