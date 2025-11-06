extends Node
@export var SOUNDS: Array[AudioStream] = []
@export var VOLUME_MULTIPLIERS: Array[float] = [] ## Easily multiplier for getting balance of audio right

@export_subgroup("Spawning") 
## For dynamically changing volume of audio (Does not change audio already added to the tree just for when initially spawned)
@export var VOLUME_MULTIPLIER: float = 1.0 
@export var PITCH_MULTIPLIER: float = 1.0 
@export var VOLUME_VARIANCE: float = 0.0
@export var PITCH_VARIANCE: float = 0.0
@export var AUDIO_BUS: String = "SFX"

@export_subgroup("Triggering Audio") 
@export var AUTO_PLAY: bool = false ## Makes audio play on load
@export var HOVER_SOUND: String = "" 
@export var PRESSED_SOUND: String = "" 
@export var HOVERED_BUTTONS: Array[Node] = [] ## Makes audio play when button is hovered
@export var PRESSED_BUTTONS: Array[Node] = [] ## Makes audio play when button is pressed

@export_subgroup("Audio Between Scenes") 
@export var ADD_TO_ROOT: bool = false ## Important for audio that is meant to play between scenes. Is added as a sibling to globals... So When calling change scene to file it doesnt get removed 
@export var AVOID_STACKING_MULTIPLE_LOADS: bool = false ## Makes it so if audio autoplays between  
@export var GROUP_NAME: String = "" ## Exclusive group name of audio (Used to kill audio)
@export var KILL_BUTTONS: Array[Button] = [] ## Frees all players in group name... For freeing meun music when game is started for example

func _ready() -> void:
	#print('test')
	if AUTO_PLAY: play_2d_sound()

	for b in KILL_BUTTONS:
		if b: b.pressed.connect(_kill_audio)
		

	for b in PRESSED_BUTTONS:
		if b.has_signal("pressed"):
			if b: b.pressed.connect(func(): play_2d_sound(PRESSED_SOUND))
		
	await get_tree().create_timer(0.1,true,false, true).timeout # Wait a second to connect the signal so hover isnt an issue
	for b in HOVERED_BUTTONS:
		if b.has_signal("mouse_entered"):
			if b: b.mouse_entered.connect(func(): play_2d_sound(HOVER_SOUND))

func play_random_child() -> void:
	var nodes = get_children()
	if nodes.size() == 0: return
	var idx = randi() % nodes.size()
	var node = nodes[idx]
	if node is AudioStreamPlayer:
		node.pitch_scale = randf_range(PITCH_MULTIPLIER - PITCH_VARIANCE, PITCH_MULTIPLIER + PITCH_VARIANCE)
		node.volume_db = linear_to_db(VOLUME_MULTIPLIER + randf_range(-VOLUME_VARIANCE, VOLUME_VARIANCE))
		node.play()
		
func play_2d_sound(sound: Variant = null) -> AudioStreamPlayer:
	
	if GROUP_NAME != "" and get_tree().get_nodes_in_group(GROUP_NAME).size() > 0:
		return get_tree().get_nodes_in_group(GROUP_NAME)[0]
	
	if sound == null:
		if SOUNDS.size() > 0:
			sound = SOUNDS[0]
		else:
			return null
	
	var base_volume = 1
	if sound is Array:
		if sound.size() == 0: return

		var final_index= randi() % sound.size()

		if sound[0] is AudioStream:
			sound = sound[final_index]
		elif sound[0] is String:
			var sound_name = sound[final_index]
			for s in SOUNDS:
				if s.resource_path.get_file().get_basename().to_lower() == sound_name.to_lower():
					#print(sound_name.to_lower())
					sound = s
					var idx = SOUNDS.find(s)
					if idx < VOLUME_MULTIPLIERS.size():
						base_volume = VOLUME_MULTIPLIERS[idx]
					break
	
	if sound is String:
		for s in SOUNDS:
			if s.resource_path.get_file().get_basename().to_lower() == sound.to_lower():
				sound = s
				var idx = SOUNDS.find(s)
				if idx < VOLUME_MULTIPLIERS.size():
					base_volume = VOLUME_MULTIPLIERS[idx]
				break
	
	if sound == null or not (sound is AudioStream):
		return null
	
	var player = AudioStreamPlayer.new()
	player.stream = sound
	player.pitch_scale = randf_range(PITCH_MULTIPLIER - PITCH_VARIANCE, PITCH_MULTIPLIER + PITCH_VARIANCE)
	#print(base_volume)
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	player.volume_db = linear_to_db(base_volume * (VOLUME_MULTIPLIER + randf_range(-VOLUME_VARIANCE, VOLUME_VARIANCE))) 
	player.bus = AUDIO_BUS
	player.connect("tree_entered", Callable(player, "play"))
	player.connect("finished", Callable(player, "queue_free"))
	if GROUP_NAME != "": player.add_to_group(GROUP_NAME)
	
	if ADD_TO_ROOT:
		var tree := Engine.get_main_loop()
		tree.get_root().call_deferred("add_child", player)
	else:
		add_child(player)
	return player

func _kill_audio() -> void:
	if GROUP_NAME == "": return
	var tree := Engine.get_main_loop()
	if tree == null or not (tree is SceneTree): return
	for n in tree.get_nodes_in_group(GROUP_NAME):
		if n is AudioStreamPlayer:
			n.queue_free()
