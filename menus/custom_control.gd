extends Node
@export var action_name: String
@export var display_name: String = ""
@export var container: Node = self
@export var deleted_sound_group: String = "control_delete_sound"
@export var add_sound_group: String = "control_add_sound"
@export var new_input_sound_group: String = "control_new_input_sound"
@export var restore_sound_group: String = "control_restore_sound"
func play_group_sound(group_name: String) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		if node is AudioStreamPlayer: node.play()
var waiting_for_new: bool = false
var last_pressed_event: InputEvent = null

@export var focus_top: Node
@export var focus_bottom: Node

func _input(event: InputEvent) -> void:
	if waiting_for_new and event.is_pressed():
		get_viewport().set_input_as_handled()
		InputMap.action_add_event(action_name, event)
		last_pressed_event = event
		waiting_for_new = false
		refresh_ui(true, 1)
		Controls.save_action_setting(action_name)
		play_group_sound(new_input_sound_group)

func create_delete_button(event: InputEvent) -> Button:
	var create_button: Button = Button.new()  
	create_button.text = Controls.get_string_from_event(event)
	create_button.pressed.connect(func() -> void:
		InputMap.action_erase_event(action_name, event)   
		Controls.save_action_setting(action_name)
		refresh_ui(true, 1)
		play_group_sound(deleted_sound_group)
		)
	return create_button

func create_add_button() -> Button:
	var add_button: Button = Button.new()
	add_button.text = "+"
	add_button.pressed.connect(func() -> void:
		waiting_for_new = true
		add_button.text = "..."		
		play_group_sound(add_sound_group)
		)
	return add_button

func create_restore_button() -> Button:
	var restore_button: Button = Button.new()
	restore_button.text = "@"
	restore_button.pressed.connect(func() -> void:
		for event in InputMap.action_get_events(action_name):
			InputMap.action_erase_event(action_name, event)
		for event in ProjectSettings.get_setting("input/" + action_name)["events"]:
			InputMap.action_add_event(action_name, event)
		refresh_ui(true, 0)
		Controls.save_action_setting(action_name)
		play_group_sound(restore_sound_group)
	)
	return restore_button

func update_focus() -> void:
	for i in range(1, container.get_child_count()): # skip index 0 (label)
		var button: Control = container.get_child(i)
		button.focus_neighbor_left = button.get_path()
		button.focus_neighbor_right = button.get_path()
		button.focus_next = button.get_path()
		button.focus_previous = button.get_path()
		#button.focus_neighbor_top = button.get_path()
		#button.focus_neighbor_bottom = button.get_path()
		
		if i > 1:button.focus_neighbor_left = container.get_child(i - 1).get_path()
		if i < container.get_child_count() - 1: button.focus_neighbor_right = container.get_child(i + 1).get_path()
	
		if focus_bottom: button.focus_neighbor_bottom = focus_bottom.get_path()
	
		if focus_top: 
			button.focus_neighbor_top = focus_top.get_path()
			focus_top.focus_neighbor_left = container.get_child(1).get_path()
			focus_top.focus_neighbor_right = container.get_child(1).get_path()
		
func refresh_ui(grab_focus: bool = false, focus_index_from_end: int = 1) -> void:
	
	for child in container.get_children(): child.queue_free()
	
	var title: Label = Label.new()   
	title.text = display_name + " - "
	container.add_child(title)
	
	for event in InputMap.action_get_events(action_name):
		container.add_child(create_delete_button(event))	
	container.add_child(create_add_button())
	container.add_child(create_restore_button())
	
	if grab_focus and container.get_child_count() > 1:
		var target_index = container.get_child_count() - (focus_index_from_end + 1)
		if target_index > 0: container.get_child(target_index).grab_focus()
	await get_tree().process_frame 	# Must await for queue free() and add_child() to complete
	await get_tree().physics_frame 	# Or else old buttons might mess up focus web.
	update_focus() # Or new buttons might not be added yet so new focus web won't complete

func _ready() -> void:

	Controls.load_action_setting(action_name)
	
	refresh_ui()
	
