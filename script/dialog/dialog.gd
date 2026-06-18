extends Node
@export_group("Dialog") 
@export var dialog_file: Resource ## Json file which specifies dialog. "Branch", "Say", "Say_Timed", Choice", etc
@export var index: int = 0 ## The current line the dialog is on...
@export var start_index_save_key: String = "" ## Used to specify when the dialog will save / start from on scene reloads or dialog ends. Auto generated if not specified
@export var anim: AnimationPlayer ## For background animations
var dialog: Array
var dialog_instance
var dialog_instance_valid_last_frame := false

@export_subgroup("Templates") ## Scene templates to spawn specified in dialog JSON f
@export var dialog_key_map : Array[String] = ["choice", "say", "say_timed"] ## For shortening dialog files. Specify what key should spawn what scene
@export var dialog_templates: Array[PackedScene] = [] ## Scene templates to spawn / despawn when the last sentence is finished
@export var dialog_group: String = "dialog" ## Group all instances of templates are added to. Used by other scrips (Such as cutscene skipper) to get rid of them

@export_group("Area")
@export var area_anim: AnimationPlayer ## For entry / exit animations from area
@export var area: Area3D ## Defines the range in which will activate conversations
@export var player_group: String = "player" ## Defines the group of bodies which can trigger conversations
var in_range: bool = false 

@export_group("Random") #wip consoldiation
@export var random_dialog: bool = false
@export var sequential: bool = false
@export var delete_after_play: bool = true ## Remove line from list after playing
@export var min_interval: float = 4.5 ## Minimum seconds between lines
@export var max_interval: float = 8.0 ## Maximum seconds between lines
@export var fail_interval: float = 0.2 ## Timeout if no line can play
@export var lines: Array[String] = [] ## Specifies which dialog branch to go to 
@export var hit_shape: Node ## Specifies the node that has 'HEALTH' and 'MAX HEALTH' For trigger hps
var random_accum: float = 0.0
var random_dialog_index: int = 0
func set_random_dialog(is_spawning: bool = false, purge_existing_dialog: bool = true) -> void:
	if purge_existing_dialog: purge_dialog()
	random_dialog = is_spawning
## Potential cool feature is save dialog so it only ever happens once or only with certain save data

func get_branch_time(start_index: int) -> float:
	var total: float = 0.0
	var i: int = start_index
	while i < dialog.size() and not dialog[i].has("branch"):
		if dialog[i].has("say_timed"):
			total += float(dialog[i].say_timed["for"])
		i += 1
	return total

func is_hp_in_range(entry: Dictionary) -> bool:
	var min_hp: float = 0.0
	var max_hp: float = 1.0
	if entry.has("min_health"): min_hp = entry["min_health"]
	if entry.has("max_health"): max_hp = entry["max_health"]
	var current_hp: float = 1.0
	if hit_shape: current_hp = hit_shape.HEALTH / hit_shape.MAX_HEALTH
	return current_hp >= min_hp and current_hp <= max_hp

func _spawn_random_dialog(delta) -> void:
	if not random_dialog: return 
	if lines.is_empty(): return

	random_accum += delta
	if random_accum < randf_range(min_interval, max_interval): return

	var entry: Dictionary = get_dictionary_for_value(lines[random_dialog_index], 1)	
	if not is_hp_in_range(entry): return
	spawn_branch(lines[random_dialog_index])		
	#print(entry)
	
	random_accum = 0
	var branch_time = get_branch_time(index)
	random_accum -= branch_time

	if delete_after_play: if random_dialog_index < lines.size(): lines.remove_at(random_dialog_index)
	
	if lines.size() > 0:# Deletion shifts array so no +1 is needed for sequential incrementation
		if sequential: random_dialog_index = random_dialog_index % lines.size() 
		else: random_dialog_index = (random_dialog_index + randi_range(1, lines.size())) % lines.size()

	#if not random_dialog_active: false

@export_group("Audio")
@export_subgroup("Jibberish")
@export var jibberish: bool = true
@export var character_delta: int = 3
@export var pitch_min: float = 0.8
@export var pitch_max: float = 1.2
@export var player: AudioStreamPlayer
@export var sounds: Array[AudioStream] = []
var last_visible := 0
var label: Label

func _play_jibberish():
	#print('test')
	if not jibberish: return
	if sounds.size() == 0: return
	if not is_instance_valid(dialog_instance): return
	var new_label := dialog_instance.find_child("Label", true, false) as Label
	if new_label != label: last_visible = 0
	label = new_label
	
	if not label or not player: return
	if label.visible_characters > label.text.length(): return
	if label.visible_characters - last_visible < character_delta: return

	#print(speaker_group)
	if sounds.size() > 0: player.stream = sounds[randi() % sounds.size()]
	player.pitch_scale = randf_range(pitch_min, pitch_max)
	player.play()
	
	#print(speaker_group)
	last_visible = label.visible_characters
	
func _on_body_entered(body) -> void:
	if not body.is_in_group(player_group): return
	if area_anim: area_anim.queue("entered")
	#print('playing enteredd')
	if Config: Config.play_animation_by_group("dialog_enable")
	in_range = true
	spawn()	

func _on_body_exited(body)-> void:
	if not body.is_in_group(player_group): return
	if area_anim: area_anim.queue("exited")
	if Config: Config.play_animation_by_group("dialog_disable")
	for child in get_children(): if child.has_method("exit_area"): child.exit_area()
	in_range = false

func _background_animation() -> void:
	# plays backgroudn animation any time dialog exists... 
	# even if player is outside of area. Call in process 
	var valid := is_instance_valid(dialog_instance)
	if valid and not dialog_instance_valid_last_frame:
		anim.queue("entered")
	elif not valid and dialog_instance_valid_last_frame:
		anim.queue("exited")
	dialog_instance_valid_last_frame = valid

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
			if dialog_group != "": instance.add_to_group(dialog_group)
			add_child(instance)
			dialog_instance = instance
	
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

func _process(_delta):
	
	_play_jibberish()
	_spawn_random_dialog(_delta)
	_background_animation()
		#print(name)
