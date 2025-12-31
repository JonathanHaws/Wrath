extends Node
@export var anim: AnimationPlayer ## For entry / exit animations from area
@export var area: Area3D ## Defines the range in which will activate conversations
@export var player_group: String = "player" ## Defines the group of bodies which can trigger conversations
@export var dialogue_templates: Array[PackedScene] = [] ## Scene templates to spawn
@export var disable_actions := ["attack", "jump"] # 

@export var start_index = 0
@export var dialogue_file: Resource
@export var SAVE_PROGRESS := false
var dialogue_save_key
var current_index = start_index
var in_range = false
var next_queued = false
var base_children = 0 ## Used to keep track of how many child dialogue scenes
var dialogue

func _on_body_entered(body) -> void:
	if not dialogue or not body.is_in_group(player_group): return
	if anim.is_playing(): anim.queue("entered")
	else: anim.play("entered")
	in_range = true
	DisableInput.toggle_action(disable_actions, false)
	_spawn_next_dialogue()

func _on_body_exited(body)-> void:
	if not body.is_in_group(player_group): return
	if anim.is_playing(): anim.queue("exited") 
	else: anim.play("exited")
	in_range = false
	DisableInput.toggle_action(disable_actions, true)
	current_index = start_index

func _spawn_next_dialogue() -> void:
	
	if current_index >= dialogue.size():
		current_index = int(start_index)
		return
		
	var entry = dialogue[current_index]	
	
	if "anim" in entry and "anim_player_group" in entry :
		for p in get_tree().get_nodes_in_group(entry.anim_player_group):
			p.play(entry.anim)	
	
	if "save" in entry and SAVE_PROGRESS:
		print('got here')
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
			add_child(instance)
		
	if "skip" in entry: current_index += 1 + entry.skip
	else: current_index += 1
	
func _ready():
	base_children = get_child_count()
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

	if dialogue_file:
		var json_as_text = FileAccess.get_file_as_string(dialogue_file.resource_path)
		dialogue = JSON.parse_string(json_as_text) as Array
		#print(dialogue)
		
	if SAVE_PROGRESS: # Load Index
		dialogue_save_key = Save.get_unique_key(self, "_dialogue_index")
		if Save.data.has(dialogue_save_key):
			current_index = int(Save.data[dialogue_save_key])
			start_index = current_index

func _process(_delta):
	if not in_range: return
	if Input.is_action_just_pressed("interact"): 
		next_queued = true
	if next_queued and  get_child_count() == base_children:
		_spawn_next_dialogue()
		next_queued = false
