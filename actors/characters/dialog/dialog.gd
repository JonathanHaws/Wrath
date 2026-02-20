extends Node
@export_group("Dialog") 
@export var dialog_file: Resource ## Json file which specifies dialog. "Branch", "Say", "Say_Timed", Choice", etc
@export var speaker_name: String = "" ## Group name... Used for jibberish audio to only apply to this entitys dialog
@export var index: int = 0 ## The current line the dialog is on...
@export var start_index_save_key: String = "" ## Used to specify when the dialog will save / start from on scene reloads or dialog ends. Auto generated if not specified
var dialog_active: bool = false
var dialog: Array

@export_subgroup("Templates") ## Scene templates to spawn specified in dialog JSON f
@export var dialog_key_map : Array[String] = ["choice", "say", "say_timed"] ## For shortening dialog files. Specify what key should spawn what scene
@export var dialog_templates: Array[PackedScene] = [] ## Scene templates to spawn / despawn when the last sentence is finished
@export var dialog_group: String = "dialog" ## Group all instances of templates are added to. Used by other scrips (Such as cutscene skipper) to get rid of them

@export_group("Area")
@export var anim: AnimationPlayer ## For entry / exit animations from area
@export var area: Area3D ## Defines the range in which will activate conversations
@export var player_group: String = "player" ## Defines the group of bodies which can trigger conversations
var in_range: bool = false 

func _on_body_entered(body) -> void:
	if not body.is_in_group(player_group): return
	if Controls: Controls.play_input_anim("dialog_enable")
	in_range = true
	spawn()	

func _on_body_exited(body)-> void:
	if not body.is_in_group(player_group): return
	if Controls: Controls.play_input_anim("dialog_disable")
	for child in get_children(): if child.has_method("exit_area"): child.exit_area()
	in_range = false

func get_dictionary_for_value(value: Variant, offset: int = 0) -> Dictionary:
	var idx: int = get_index_for_value(value) + offset
	if dialog and idx >= 0 and idx < dialog.size():
		return dialog[idx]
	return {}
	
func get_index_for_value(value: Variant) -> int:
	var value_index = index
	if value is String:
		for line in range(dialog.size()):
			if dialog[line].has("branch") and dialog[line].branch == value:
				value_index = line
				break
	elif value is int: value_index = value
	if value_index > dialog.size():index = int(Save.data.get(get_start_key, 0))
	return value_index
		
func get_start_key() -> String:
	if start_index_save_key != "": return start_index_save_key
	else: return Save.get_unique_key(self, "start_index_save_key")

func end() -> void:
	index = int(Save.data.get(get_start_key(), 0))
	for child in get_children(): if child.has_method("exit_area"): child.exit_area()

func purge_dialog() -> void:
	for node in get_tree().get_nodes_in_group(dialog_group): node.queue_free()

func _is_dialog_in_tree() -> bool:
	var dialog_in_tree: Array = get_tree().get_nodes_in_group(dialog_group)
	if dialog_in_tree.size() == 0: return false
	if speaker_name != "":
		for n in dialog_in_tree:
			if n.is_in_group(speaker_name):
				return true
		return false
	return true 

func goto(value: Variant) -> void:
	index = get_index_for_value(value)

func spawn_branch(value: Variant) -> void:
	index = get_index_for_value(value)
	spawn()

func spawn() -> void:
	
	purge_dialog()
	
	var entry = dialog[index]	
	
	for i in range(dialog_key_map.size()):
		var key = dialog_key_map[i]
		if entry.has(key):
			var instance = dialog_templates[i].instantiate()
			instance.dialog = self
			instance.info = entry[key]
			if speaker_name != "": instance.add_to_group(speaker_name)
			if dialog_group != "": instance.add_to_group(dialog_group)
			add_child(instance)
	
	if "start" in entry:
		Save.data[get_start_key()] = index
	
	if "save" in entry:
		if entry.save is Dictionary and entry.save.has("key") and entry.save.has("value"):
			Save.data[entry.save.key] = entry.save.value
		
	if "anim" in entry:
		if "anim_player_group" in entry :
			for p in get_tree().get_nodes_in_group(entry.anim_player_group):
				p.play(entry.anim)		
	
	if "end" in entry: 
		end()
		
	if "skip" in entry: 
		goto(entry.skip)

	if "branch" in entry:
		if index < (dialog.size()-1):
			index += 1 ## Skip past branch labels
			spawn()
			return

func _ready():
	
	index = int(Save.data.get(get_start_key(), index))

	if dialog_file: # Load JSON file
		var json_as_text = FileAccess.get_file_as_string(dialog_file.resource_path)
		dialog = JSON.parse_string(json_as_text) as Array
		#print(dialog)

	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	#print(get_tree().get_nodes_in_group(dialog_group).size())
	#print(start_index, " ", index)
	
	var active: bool = _is_dialog_in_tree() # Poll to see if dialog is active
	if active and not dialog_active:
		anim.queue("entered")
	elif not active and dialog_active:
		anim.queue("exited")
	dialog_active = active
