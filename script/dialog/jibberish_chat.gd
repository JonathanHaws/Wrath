extends Node
## Group containing the Label whos advacement controls playback...
## Could also be used to use different sounds for different emotions eg. (angry_chat_label, sad_chat_label) etc
@export_group("Sounds")
@export var character_delta: int = 3
@export var pitch_min: float = 0.8
@export var pitch_max: float = 1.2
@export var player: AudioStreamPlayer
@export var sounds: Array[AudioStream] = []
@export_group("Groups") ## Node must be in these groups to trigger jibberish
@export var chat_group: String = "chat" 
@export var speaker_group: String = ""
var last_visible := 0
var label: Label

func _is_in_speaker_group(node: Node) -> bool:
	if speaker_group == "": return true
	var n: Node = node # Bandaid Check if parent is speaker...
	while n:# Probably better way to do it but alright for now 
		if n.is_in_group(speaker_group):
			return true
		n = n.get_parent()
	return false

func _process(_delta):
	#print('test')
	var new_label = get_tree().get_first_node_in_group(chat_group) # Will dynamically detect new labels 
	if new_label != label: last_visible = 0
	label = new_label
	if not label or not player: return
	if label.visible_characters > label.text.length(): return
	if label.visible_characters - last_visible < character_delta: return

	if not _is_in_speaker_group(label): return

	if sounds.size() > 0:
		player.stream = sounds[randi() % sounds.size()]

	player.pitch_scale = randf_range(pitch_min, pitch_max)
	player.play()
	last_visible = label.visible_characters
