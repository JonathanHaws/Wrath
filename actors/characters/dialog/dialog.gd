extends Node
@export var anim: AnimationPlayer ## For entry / exit animations from area
@export var area: Area3D ## Defines the range in which will activate conversations
@export var player_group: String = "player" ## Defines the group of bodies which can trigger conversations

@export var start_index = 0
@export var dialog_file: Resource
@export var SAVE_PROGRESS := false
@export var disable_actions := ["attack", "jump"] ## Requires DisableInput global to work
@export var conversation_templates: Array[PackedScene] = [] ## Scenes to spawn / despawn when the conversation is finished (area range exited) [NOT IMPLEMENTED YET]

@export var dialog_templates: Array[PackedScene] = [ ## Scene templates to spawn / despawn when the last sentence is finished
	load("res://actors/characters/dialog/scenes/chat.tscn"),
	load("res://actors/characters/dialog/scenes/choice.tscn"),]
@export var dialog_key_map := { ## For shortening dialog files. Specify what key should spawn what scene
	"say":0, 
	"choice":1,}
	
var dialog_save_key
var current_index = start_index
var in_range = false
var dialog
var entry

func _on_body_entered(body) -> void:
	if not dialog or not body.is_in_group(player_group): return
	if DisableInput: DisableInput.toggle_action(disable_actions, false)
	anim.queue("entered")
	in_range = true
	_spawn_next_dialog()

func _on_body_exited(body)-> void:
	if not body.is_in_group(player_group): return
	if DisableInput: DisableInput.toggle_action(disable_actions, true)
	_end_dialog()

func _end_dialog() -> void:
	if in_range: anim.queue("exited") 
	in_range = false
	current_index = start_index

func skip_to(value) -> void:
	for i in range(dialog.size()):
		var entry = dialog[i]
		if entry.has("fork") and entry.fork == value:
			current_index = i
			return

func _spawn_next_dialog() -> void:
	
	if not in_range: return
	if current_index >= dialog.size(): # Loop back
		current_index = int(start_index)
		return
	while current_index < dialog.size() and dialog[current_index].has("fork"): # Skip fork labels
		current_index += 1		
	if current_index < dialog.size(): entry = dialog[current_index]	
	
	if "save" in entry and SAVE_PROGRESS:
		Save.data[dialog_save_key] = current_index
		start_index = current_index
		Save.save_game()
	
	for key in dialog_key_map.keys():
		if entry.has(key):
			var instance = dialog_templates[dialog_key_map[key]].instantiate()
			instance.info = entry[key]
			instance.tree_exited.connect(_spawn_next_dialog) 
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
		
	if SAVE_PROGRESS: # Load how far the dialog has progressed (start_index)
		dialog_save_key = Save.get_unique_key(self, "_dialog_index")
		if Save.data.has(dialog_save_key):
			current_index = int(Save.data[dialog_save_key])
			start_index = current_index
