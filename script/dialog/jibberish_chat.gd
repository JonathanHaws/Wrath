extends Node
## Group containing the Label whos advacement controls playback...
## Could also be used to use different sounds for different emotions eg. (angry_chat_label, sad_chat_label) etc

@export var chat_group: String = "chat" 
@export var speaker_group: String = ""
@export var character_delta: int = 3
@export var pitch_min: float = 0.8
@export var pitch_max: float = 1.2
@export var player: AudioStreamPlayer
@export var sounds: Array[AudioStream] = []
var last_visible := 0
var label: Label

func _process(_delta):
	#print('test')
	var new_label = get_tree().get_first_node_in_group(chat_group) # Will dynamically detect new labels 
	if new_label != label: last_visible = 0
	label = new_label
	if not label or not player: return
	if label.visible_characters > label.text.length(): return
	if label.visible_characters - last_visible < character_delta: return

	if not label.is_in_group(speaker_group): return # A label exists but its someone else who is speaking

	#print(speaker_group)
	if sounds.size() > 0:
		player.stream = sounds[randi() % sounds.size()]

	player.pitch_scale = randf_range(pitch_min, pitch_max)
	player.play()
	last_visible = label.visible_characters
