extends Node
@export var anim: AnimationPlayer ## For entry / exit animations from area
@export var area: Area3D ## Defines the range in which will activate conversations
@export var player_group: String = "player" ## Defines the group of bodies which can trigger conversations
@export var dialogue_templates: Array[PackedScene] = [] ## Scene templates to spawn
@export var disable_actions := ["attack", "jump"] ## Requires DisableInput global

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
	anim.queue("exited") 
	in_range = false
	current_index = start_index

func _spawn_next_dialogue() -> void:
	
	if not in_range: return
	var entry = dialogue[current_index]	
	
	if current_index >= dialogue.size(): # Loop back
		current_index = int(start_index)
		return
		
	if "anim" in entry and "anim_player_group" in entry :
		for p in get_tree().get_nodes_in_group(entry.anim_player_group):
			p.play(entry.anim)	
	
	if "save" in entry and SAVE_PROGRESS:
		Save.data[dialogue_save_key] = current_index
		start_index = current_index
		Save.save_game()
	
	if entry.has("scene"):	
		var scene_index = int(entry.scene)
		if scene_index >= 0 and scene_index < dialogue_templates.size():
			if not dialogue_templates[scene_index]: return
			var instance = dialogue_templates[scene_index].instantiate()
			if "info" in entry and "info" in instance:
				instance.info = entry.info
			# Recursively chain dialoguye by spawning another sentence when this one is finished
			instance.tree_exited.connect(_spawn_next_dialogue) 
			add_child(instance)
		
	if "skip" in entry: current_index += 1 + entry.skip
	else: current_index += 1
	
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
