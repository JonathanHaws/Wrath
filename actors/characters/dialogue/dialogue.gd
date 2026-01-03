extends Node
@export var anim: AnimationPlayer ## For entry / exit animations from area
@export var area: Area3D ## Defines the range in which will activate conversations
@export var player_group: String = "player" ## Defines the group of bodies which can trigger conversations
@export var disable_actions := ["attack", "jump"] ## Requires DisableInput global
@export var conversation_templates: Array[PackedScene] = [] ## Scenes to spawn / despawn when the conversation is finished (area range exited) [NOT IMPLEMENTED YET]
@export var dialogue_templates: Array[PackedScene] = [] ## Scene templates to spawn / despawn when the last sentence is finished
@export var dialog_key_map := { ## For shortening dialog files. Specify what key should spawn what scene
	"say":0, 
	"choice":1, 
}

@export var start_index = 0
@export var dialogue_file: Resource
@export var SAVE_PROGRESS := false
var dialogue_save_key
var current_index = start_index
var in_range = false
var dialogue

func _on_body_entered(body) -> void:
	if not dialogue or not body.is_in_group(player_group): return
	if DisableInput: DisableInput.toggle_action(disable_actions, false)
	anim.queue("entered")
	in_range = true
	_spawn_next_dialogue()

func _on_body_exited(body)-> void:
	if not body.is_in_group(player_group): return
	if DisableInput: DisableInput.toggle_action(disable_actions, true)
	_end_dialogue()

func _end_dialogue() -> void:
	if in_range: anim.queue("exited") 
	in_range = false
	current_index = start_index

func skip_to(value) -> void:
	if typeof(value) == TYPE_STRING: # Skip to fork
		for i in range(dialogue.size()):
			var entry = dialogue[i]
			if entry.has("fork") and entry.fork == value:
				current_index = i
				return
	else: # Skip number of sentences
		current_index += value
	
func _spawn_next_dialogue() -> void:
	
	if not in_range: return
	if current_index >= dialogue.size(): # Loop back
		current_index = int(start_index)
		return
	var entry = dialogue[current_index]	
	
	if "save" in entry and SAVE_PROGRESS:
		Save.data[dialogue_save_key] = current_index
		start_index = current_index
		Save.save_game()
	
	for key in dialog_key_map.keys():
		if entry.has(key):
			var instance = dialogue_templates[dialog_key_map[key]].instantiate()
			instance.info = entry[key]
			instance.tree_exited.connect(_spawn_next_dialogue) 
			add_child(instance)
			
	if "skip" in entry: 
		skip_to(entry.skip)
	else:
		current_index += 1
		
	if "anim" in entry and "anim_player_group" in entry :
		for p in get_tree().get_nodes_in_group(entry.anim_player_group):
			p.play(entry.anim)		

	if "start" in entry: start_index = current_index
	if "end" in entry: _end_dialogue()
	
func _ready():

	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

	if dialogue_file: # Load JSON file
		var json_as_text = FileAccess.get_file_as_string(dialogue_file.resource_path)
		dialogue = JSON.parse_string(json_as_text) as Array
		#print(dialogue)
		
	if SAVE_PROGRESS: # Load how far the dialogue has progressed (start_index)
		dialogue_save_key = Save.get_unique_key(self, "_dialogue_index")
		if Save.data.has(dialogue_save_key):
			current_index = int(Save.data[dialogue_save_key])
			start_index = current_index
