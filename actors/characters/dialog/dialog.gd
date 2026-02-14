extends Node
@export_subgroup("Area")
@export var anim: AnimationPlayer ## For entry / exit animations from area
@export var area: Area3D ## Defines the range in which will activate conversations
@export var player_group: String = "player" ## Defines the group of bodies which can trigger conversations
@export var disable_actions := ["attack", "jump"] ## Requires DisableInput global to work

@export_group("Templates") ## Scene templates to spawn specified in dialog JSON file
@export var dialog_key_map : Array[String] = ["choice", "say", "say_timed"] ## For shortening dialog files. Specify what key should spawn what scene
@export var dialog_templates: Array[PackedScene] = [] ## Scene templates to spawn / despawn when the last sentence is finished
@export var dialog_group: String = "dialog" ## Group all instances of templates are added to. Used by other scrips (Such as cutscene skipper) to get rid of them
@export var speaker_name: String = "" ## Group name... Used for jibberish audio to only apply to this entitys dialog

@export_group("Dialog") ## Control dialog flow with "fork: name", "skip: fork_name", save, start, end
@export var dialog_file: Resource
@export var start_index = 0
var index = start_index
var in_range: bool = false 
var dialog_active := false
var dialog_save_key
var dialog
var entry
	
func _on_body_entered(body) -> void:
	if not body.is_in_group(player_group): return
	if Controls: Controls.play_input_anim("dialog_enable")
	in_range = true
	_spawn()
	
func _on_body_exited(body)-> void:
	if not body.is_in_group(player_group): return
	if Controls: Controls.play_input_anim("dialog_disable")
	in_range = false
	_end_dialog()

func _end_dialog() -> void:
	index = start_index
	for child in get_children(): if child.has_method("exit_area"): child.exit_area()

func get_index_for_value(value: Variant) -> int:
	var idx = index
	if value is String:
		for line in range(dialog.size()):
			if dialog[line].has("fork") and dialog[line].fork == value:
				idx = line
				break
	elif value is int: idx = value
	if idx >= dialog.size(): idx = int(start_index) ## Loop back
	return idx

func get_dictionary_for_value(value: Variant, offset: int = 0) -> Dictionary:
	var idx: int = get_index_for_value(value) + offset
	if dialog and idx >= 0 and idx < dialog.size():
		return dialog[idx]
	return {}

func goto(value: Variant) -> void:
	index = get_index_for_value(value)

func _spawn_fork(value: Variant) -> void:
	index = get_index_for_value(value)
	_spawn()

func _spawn(require_in_range = false) -> void:
	if require_in_range and not in_range: return
	entry = dialog[index]	
	
	for i in range(dialog_key_map.size()):
		var key = dialog_key_map[i]
		if entry.has(key):
			var instance = dialog_templates[i].instantiate()
			instance.info = entry[key]
			if speaker_name != "": instance.add_to_group(speaker_name)
			if dialog_group != "": instance.add_to_group(dialog_group)
			add_child(instance)
	
	if "fork" in entry:
		if index < (dialog.size()-1):
			index += 1 ## Skip past fork labels
			_spawn()
			return
	
	if "save" in entry:
		Save.data[dialog_save_key] = index
		start_index = index
		Save.save_game()		
	
	if "anim" in entry:
		if "anim_player_group" in entry :
			for p in get_tree().get_nodes_in_group(entry.anim_player_group):
				p.play(entry.anim)		
	
	if "start" in entry: 
		start_index = index
	
	if "end" in entry: 
		_end_dialog()
	
	if "skip" in entry: 
		goto(entry.skip)
		return
	
	goto(index + 1)
	
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
		index = int(Save.data[dialog_save_key])
		start_index = index

func _is_dialog_in_tree() -> bool:
	var dialog_in_tree: Array = get_tree().get_nodes_in_group(dialog_group)
	if dialog_in_tree.size() == 0: return false
	if speaker_name != "":
		for n in dialog_in_tree:
			if n.is_in_group(speaker_name):
				return true
		return false
	return true 
	
func _physics_process(_delta: float) -> void:
	#print(get_tree().get_nodes_in_group(dialog_group).size())
	
	var active: bool = _is_dialog_in_tree() # Poll to see if dialog is active
	if active and not dialog_active:
		anim.queue("entered")
	elif not active and dialog_active:
		anim.queue("exited")
	dialog_active = active
