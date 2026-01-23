extends Node
@export_subgroup("Area")
@export var anim: AnimationPlayer ## For entry / exit animations from area
@export var area: Area3D ## Defines the range in which will activate conversations
@export var player_group: String = "player" ## Defines the group of bodies which can trigger conversations
@export var disable_actions := ["attack", "jump"] ## Requires DisableInput global to work
@export_group("Templates") ## Scene templates to spawn specified in dialog JSON file
@export var dialog_key_map : Array[String] = ["choice", "say", "say_timed"] ## For shortening dialog files. Specify what key should spawn what scene
@export var dialog_templates: Array[PackedScene] = [] ## Scene templates to spawn / despawn when the last sentence is finished
@export var dialog_group: String = "dialog" ## Group all instances of templates are added to. 
@export_group("Dialog") ## Control dialog flow with "fork: name", "skip: fork_name", save, start, end
@export var dialog_file: Resource
@export var start_index = 0
var current_index = start_index
var in_range: bool = false 
var dialog_active := false
var dialog_save_key
var dialog
var entry
	
func _on_body_entered(body) -> void:
	if not body.is_in_group(player_group): return
	if DisableInput: DisableInput.toggle_action(disable_actions, false)
	in_range = true
	_spawn()
	
func _on_body_exited(body)-> void:
	if not body.is_in_group(player_group): return
	if DisableInput: DisableInput.toggle_action(disable_actions, true)
	in_range = false
	_end_dialog()

func _end_dialog() -> void:
	current_index = start_index
	for child in get_children(): if child.has_method("exit_area"): child.exit_area()

func skip_to(value: String) -> void:
	for line in range(dialog.size()):
		if dialog[line].has("fork") and dialog[line].fork == value:
			current_index = line
			return

func play_fork(value: String) -> void: # Called in animation players 
	skip_to(value)
	_spawn()

func _spawn(require_in_range = false) -> void:
	
	if require_in_range and not in_range: return
	if current_index >= dialog.size(): current_index = int(start_index) # Loop back
	while current_index < (dialog.size()-1) and dialog[current_index].has("fork"): current_index += 1 # Skip fork labels
	entry = dialog[current_index]	
	
	if "save" in entry:
		Save.data[dialog_save_key] = current_index
		start_index = current_index
		Save.save_game()
	
	for i in range(dialog_key_map.size()):
		var key = dialog_key_map[i]
		if entry.has(key):
			var instance = dialog_templates[i].instantiate()
			instance.info = entry[key]
			instance.add_to_group(dialog_group)
			add_child(instance)
			
	if "skip" in entry: skip_to(entry.skip)
	else: current_index += 1
		
	if "anim" in entry and "anim_player_group" in entry :
		for p in get_tree().get_nodes_in_group(entry.anim_player_group):
			p.play(entry.anim)		

	if "start" in entry: start_index = current_index
	if "end" in entry: _end_dialog()
	
func _ready():

	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

	if dialog_file: # Load JSON file
		var json_as_text = FileAccess.get_file_as_string(dialog_file.resource_path)
		dialog = JSON.parse_string(json_as_text) as Array
		#print(dialog)
		
	dialog_save_key = Save.get_unique_key(self, "_dialog_index")  # Load how far the dialog has progressed (start_index)
	if Save.data.has(dialog_save_key):
		current_index = int(Save.data[dialog_save_key])
		start_index = current_index

func _physics_process(_delta: float) -> void:
	#print(get_tree().get_nodes_in_group(dialog_group).size())
	
	var active := get_tree().get_nodes_in_group(dialog_group).size() > 0 # Poll to see if dialog is active
	if active and not dialog_active:
		anim.queue("entered")
	elif not active and dialog_active:
		anim.queue("exited")
	dialog_active = active
